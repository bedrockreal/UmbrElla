.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

# force manual swing, and set practice swing on A-A
# TODO: fix putting
# 1. don't draw right-to-left slider on auto swing
.long	0xc6475738
.long	0x804758d0
# 2. no RNG timing
.long	0x04475ba4
nop
# 3. allow 3rd click on auto shot
.long	0x0441405c
nop
# 4. no real shot if impact mode == auto
.long	0x06414348
.long	0x00000014
li		30, 0
li		0, ACTION_STATE_IDLE
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(31)
stb		30, LIE_DISPLAY_MODE_FROM_PLAYER_PARAMETERS(31)
.long	0x4800000c
.zero	4

# 5. no impact anim on auto swing
# 5.1: change if condition implementation
# .long	0x06426148
# .long	0x00000028
# 
# lis		11, IMPACT_STRUCT_ADDR@ha


.long	0xc2426148
.long	0x00000009

# actionState == 12 && impact mode == auto && timer > 0 -> force no advance

# r11, r9 free
# check auto swing && impact timing > 0
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		11, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	11, ACTION_STATE_SWING
lwz		11, IMPACT_MODE_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 11, 1
lis		9, IMPACT_TIMER_FOR_ANIM@ha
lwz		11, IMPACT_TIMER_FOR_ANIM@l(9)
cmpwi	cr6, 11, 0
crand	cr7*4+eq, cr7*4+eq, cr6*4+gt
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end_delay_anim

# force no advance anim
.set	JUMP_ADDR,	0x80426170
lis		9, JUMP_ADDR@h
ori		9, 9, JUMP_ADDR@l
mtctr	9
bctr

end_delay_anim:
# the original instr.
cmpwi	7, 0

nop
.zero	4

# 6. fix range marker after practice swing
.long	0x044150ac
nop

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

# .if		(BUTTON_PRESS_FROM_PLAYER_PARAMETERS == 0)
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
# .endif

# 9. don't increment stroke count
# TODO: if 'three-click putting' isn't activated, need increment stroke on A-A putt
.long	0xc2413ef4
.long	0x00000005

lhz		9, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(31)
andi.	9, 9, 0x100
beq		end_skip_increment_stroke

lis		9, 0x8041
ori		9, 9, 0x3f30
mtctr	9
bctr

end_skip_increment_stroke:
lwz		9, 0x25c(31)

nop
.zero	4

# 10. don't decrement power shot
# TODO

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
