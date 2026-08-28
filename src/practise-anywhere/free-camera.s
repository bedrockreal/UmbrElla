# note: the game crashes upon entering training mode if you apply this code alongside other codes on a real Wii (perhaps also GameCube).

.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

# inject the main code
.long	0xc2424fb0
.long	35

# note: r6, r7, r8 and r11 are free

# restore replaced instruction
stw		0, 0x1c4(1)

# rearrange instructions to optimise
# load constants
# r6 := button hold mask
# r7 := button press mask
# r9 := player params
# r11 := 0x80000000
lis		11, FREE_CAMERA_STATUS_ADDR@ha
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		6, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
lhz		7, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)

free_camera_start:
lwz		0, FREE_CAMERA_STATUS_ADDR@l(11)
cmpwi	0, FREE_CAMERA_ACTIVE
beq		free_camera_mode

free_camera_activate_check:
# check (r3 := actionState) == IDLE
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, ACTION_STATE_IDLE
bne		free_camera_end

# here r3 == 0, r9 == player parameters
# check Z hold + X press
cmpwi	cr7, 6, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
subic.	10, 7, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		free_camera_end

# enter free camera mode
li		0, ACTION_STATE_PANNING
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

# clear FREE_CAMERA_DELTA_ADDR
# hack: r3 == 0 if we reach here
.set	DX, FREE_CAMERA_DELTA_ADDR
.set	DZ, FREE_CAMERA_DELTA_ADDR+4
.set	DY, FREE_CAMERA_DELTA_ADDR+8
stw		3, DX@l(11)
stw		3, DZ@l(11)
stw		3, DY@l(11)

li		3, FREE_CAMERA_ACTIVE
b		write_free_camera

free_camera_mode:
# iff Z held, load analogue stick using paired singles instructions
# note: if control reaches here, it must be from the 'beq' instruction above. r9 contains the player parameters ptr and is not nodified
andi.	5, 6, MODIFIER_MASK
beq		end_load_analogue_stick
psq_l	13, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS(9), 0, 0

# add analogue delta to free camera coordinates
addi	8, 11, FREE_CAMERA_DELTA_ADDR@l

# swap the floats in f13 first (y, z) -> (z, y), then add and store
ps_merge10		13, 13, 13
psq_l	12, 0x4(8), 0, 0
ps_add	12, 12, 13
psq_st	12, 0x4(8), 0, 0

end_load_analogue_stick:

check_drop_ball:
# check if already in drop ball state
lwz		10, DROP_BALL_STATUS_ADDR@l(11)
cmpwi	10, DROP_BALL_PROCEED
beq		drop_ball_third_pass

# press the free camera activate combo to drop ball in practice mode
lis		8, GAME_MODE_ADDR@ha
lwz		10, GAME_MODE_ADDR@l(8)
cmpwi	10, GAME_MODE_PRACTICE
cmpwi	cr6, 6, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
cmpwi	cr7, 7, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr6*4+eq, cr6*4+eq, cr7*4+eq
crand	cr0*4+eq, cr6*4+eq, cr0*4+eq
bne		free_camera_check_exit

# in drop ball state now

drop_ball_first_pass:
li		10, ACTION_STATE_SWING
stw		10, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
li		10, DROP_BALL_PROCEED
lis		8, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(8)

# now r10 must be fixed
# set the ball's position
# load
# addi	8, 11, FREE_CAMERA_ABS_COORDS_ADDR@l
# lswi	3, 8, 12
.set	__MOD_BALL_POS_LOAD__, FREE_CAMERA_ABS_COORDS_ADDR + 8
.set	__MOD_BALL_POS_STORE1__, BALL_FLYING_STATE_FROM_BASE+BALL_POSITION_FROM_BALL_FLYING_STATE
.set	__MOD_BALL_POS_STORE2__, __MOD_BALL_POS_STORE1__+8

lfd		13, FREE_CAMERA_ABS_COORDS_ADDR@l(11)
lfs		12, __MOD_BALL_POS_LOAD__@l(11)

# store
lwz		8, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
stfd	13, __MOD_BALL_POS_STORE1__(8)
stfs	12, __MOD_BALL_POS_STORE2__(8)
# addi	8, 8, BALL_FLYING_STATE_FROM_BASE+BALL_POSITION_FROM_BALL_FLYING_STATE
# stswi	3, 8, 12

b		drop_ball_store_status

drop_ball_third_pass:
li		10, GREAT_GAMEPLAY_STATUS_BALL_FLYING
stw		10, GAMEPLAY_STATUS_FROM_GREAT_PLAYER_STATE(31)
# also increment stroke count
lwz		8, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
lbz		10, HOLE_STROKE_COUNT_FROM_BASE(8)
addi	10, 10, 1
stb		10, HOLE_STROKE_COUNT_FROM_BASE(8)

# done -> set status := inactive
li		10, DROP_BALL_INACTIVE
lis		8, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(8)

# note: fall through to drop_ball_store_status

drop_ball_store_status:
stw		10, DROP_BALL_STATUS_ADDR@l(11)

# this is needed
cmpwi	10, DROP_BALL_INACTIVE
beq		exit_free_camera_mode
b		free_camera_end

free_camera_check_exit:
# exit if anything not in IGNORE_BUTTON_MASK is pressed
andi.	0, 7, FREE_CAMERA_EXIT_BUTTON_MASK
beq		free_camera_end

exit_free_camera_mode:
li		3, FREE_CAMERA_INACTIVE

write_free_camera:
stw		3, FREE_CAMERA_STATUS_ADDR@l(11)

free_camera_end:
.zero	4

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
