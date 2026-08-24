.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

# force manual swing, and set practice swing on A-A
# TODO: fix putting, fix slider on 2nd click
# 1. don't draw right-to-left slider on auto swing
.long	0xc6475720
.long	0x804758d0

# 2. no RNG timing
.long	0x04475ba4
nop

# 3. allow 3rd click on auto shot
.long	0x0441405c
nop
# 4. no real shot if impact mode == auto
# note: at 0x80414348, r9 := great player state
# note: r10 == 0x80530000
.long	0x0641434c
.long	0x00000044
li		30, 0
stw		30, 0x7398(10) # set power meter display mode = 0, so that rangee marker can be seen
li		0, ACTION_STATE_IDLE
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(31)

# 4.2: restore stroke count
#                              Increment stroke count
#                              LAB_80413ef4                                    XREF[1]:     80413e1c(j)  
#         80413ef4 81 3f 02 5c     lwz        r9,0x25c(r31)
#         80413ef8 81 69 00 08     lwz        r11,0x8(r9)
#         80413efc 89 2b 01 bc     lbz        r9,0x1bc(r11)
#         80413f00 39 29 00 01     addi       r9,r9,0x1
#         80413f04 99 2b 01 bc     stb        r9,0x1bc(r11)
#         80413f08 81 3f 02 5c     lwz        r9,0x25c(r31)
#         80413f0c 80 69 00 18     lwz        param_1,0x18(r9)
#         80413f10 48 00 13 d9     bl         FUN_804152e8                                     undefined FUN_804152e8(undefined
#         80413f14 2c 03 00 00     cmpwi      param_1,0x0
#         80413f18 41 82 00 18     beq        LAB_80413f30
#         80413f1c 81 3f 02 5c     lwz        r9,0x25c(r31)
#         80413f20 81 69 00 08     lwz        r11,0x8(r9)
#         80413f24 89 2b 01 bd     lbz        r9,0x1bd(r11)
#         80413f28 39 29 00 01     addi       r9,r9,0x1
#         80413f2c 99 2b 01 bd     stb        r9,0x1bd(r11)

lwz		11, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(9)
lbz		3, HOLE_STROKE_COUNT_FROM_BASE(11)
subi	3, 3, 1
stb		3, HOLE_STROKE_COUNT_FROM_BASE(11)

lwz		3, 0x18(9)

# this is 0x80414370, bl to 0x804152e8
.long	0x48000f39

cmpwi	3, 0
beq		end_restore_stroke_count

lwz		9, GREAT_PLAYER_STATE_FROM_PLAYER_PARAMETERS(31)
lwz		11, BALL_POSITION_FROM_BALL_FLYING_STATE(9)
lbz		3, ROUND_STROKE_COUNT_FROM_BASE(11)
subi	3, 3, 1
stb		3, ROUND_STROKE_COUNT_FROM_BASE(11)

end_restore_stroke_count:
nop

# 5. no impact anim on auto swing

.long	0xc2426148
.long	0x0000000c
# actionState == 12 && impact mode == auto && timer + anim frame >= 100 -> force no advance

# r11, r9 free
# check auto swing && impact timing > 0

# check actionState == 12
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		11, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	11, ACTION_STATE_SWING

# check auto swing
lwz		11, IMPACT_MODE_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 11, 1

# load timer
lis		9, IMPACT_TIMER_FOR_ANIM@ha
lwz		11, IMPACT_TIMER_FOR_ANIM@l(9)
lwz		9, ANIM_FROM_GREAT_PLAYER_STATE(31)

# load animation stopwatch, make it an integer
# storing at FREE_CAMERA_ABS_COORDS_ADDR is fine as it would be overwritten in free camera mode
lfs		0, STOPWATCH_FROM_ANIM(9)
fctiwz	13, 0
lis		9, FREE_CAMERA_ABS_COORDS_ADDR@h
stfdu	13, FREE_CAMERA_ABS_COORDS_ADDR@l(9)
lwz		9, 0x4(9)

# check timer + stopwatch >= 100
add		11, 11, 9
cmpwi	cr6, 11, 99
crand	cr7*4+eq, cr7*4+eq, cr6*4+gt
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end_delay_anim

# force no advance anim: jump to 0x80426170
lis		9, 0x8042
ori		9, 9, 0x6170
mtctr	9
bctr

end_delay_anim:
# the original instr.
cmpwi	7, 0

.zero	4

# 6. fix range marker after practice swing
.long	0xc24150ac
.long	4
lwz		3, IMPACT_MODE_FROM_PLAYER_PARAMETERS(31)
subic.	3, 3, 1
bne+	end_skip_update_range_marker

# the fix: set 0x1d0(31) := range marker, then impact mode := 0
lwz		0, 0x73a0(11)
stw		0, SWING_POWER_FROM_PLAYER_PARAMETERS(31)
stw		3, IMPACT_MODE_FROM_PLAYER_PARAMETERS(31)

end_skip_update_range_marker:
stw		0, 0x73a0(11)
.zero	4

# 7. reset Mario on 1st press
.long	0xc2413ca4
.long	0x00000002

# note: r11 == impact struct addr.
stw		9, MARIO_THUMBS_UP_FROM_IMPACT_STRUCT(11)

# the original instr.
li		0, 0xb

nop
.zero	4

# 8. don't modify lie (works now)
# 8.1 rearrange instrs.
# hack using sth over stb to save 2 instrs
.long	0x06413d0c
.long	0x00000010

li		0, 0
sth		0, 0x24c(31)
sth		0, 0x248(31)
lhz		9, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(31)

.long	0x04413d20
cmpwi	10, 0
# 8.2: check if A pressed: if yes, skip lie RNG code

.long	0xc2413d1c
.long	0x00000004

# if A pressed, jump
andi.	9, 9, 0x100
beq		end_skip_lie_collapse

lis		9, 0x8041
ori		9, 9, 0x3ddc
mtctr	9
bctr

end_skip_lie_collapse:
nop
.zero	4

# 8.3: on auto swing, don't set lie display mode
.long	0x04413e7c
nop

.long	0xc2413fcc
.long	0x00000002

lwz		9, IMPACT_MODE_FROM_PLAYER_PARAMETERS(31)
# 0 -> 2, 1 -> 0
subi	9, 9, 1
rlwinm	9, 9, 1, 30, 30
.zero	4

# 9. don't decrement power shot
# TODO

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
