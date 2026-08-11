#+ 20416dbc 3f608039
#+ c2424fb0 000000..

# note: split free camera driver code apart

.include "constants.asm"

# restore replaced instruction
stw		0, 0x1c4(1)

free_camera_start:
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		0, FREE_CAMERA_STATUS_ADDR@l(9)
cmpwi	0, FREE_CAMERA_ACTIVE
beq		free_camera_mode

free_camera_activate_check:
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
addic.	3, 3, -ACTION_STATE_IDLE
bne		free_camera_end

# check Z hold + X press
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	10, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		free_camera_end

# enter free camera mode
li		0, ACTION_STATE_PANNING
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

li		5, 0
li		6, 0
li		7, 0
lis		9, FREE_CAMERA_DELTA_ADDR@ha
addi	9, 9, FREE_CAMERA_DELTA_ADDR@l
stswi	5, 9, 12

li		3, FREE_CAMERA_ACTIVE
b		write_free_camera

free_camera_mode:
# load analogue stick, and force it to zero
li		0, 0
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lfs		13, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS(9)
stw		0, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS(9)
lfs		12, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS+0x4(9)
stw		0, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS+0x4(9)

# add analogue delta to free camera coordinates
lis		9, FREE_CAMERA_DELTA_ADDR@ha
addi	9, 9, FREE_CAMERA_DELTA_ADDR@l
lfs		0, 0x8(9) # y
fadds	0, 13, 0
stfs	0, 0x8(9)
lfs		0, 0x4(9) # z
fadds	0, 12, 0
stfs	0, 0x4(9)

check_drop_ball:
# check if already in drop ball state
lis		9, DROP_BALL_STATUS_ADDR@ha
lwz		10, DROP_BALL_STATUS_ADDR@l(9)
cmpwi	10, DROP_BALL_PROCEED
beq		drop_ball_third_pass

# press the free camera activate combo to drop ball in practice mode
lis		9, GAME_MODE_ADDR@ha
lwz		10, GAME_MODE_ADDR@l(9)
cmpwi	10, GAME_MODE_PRACTICE
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr6, 10, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr6*4+eq, cr6*4+eq, cr7*4+eq
crand	cr0*4+eq, cr6*4+eq, cr0*4+eq
bne		free_camera_check_exit

# in drop ball state now

drop_ball_first_pass:
li		10, ACTION_STATE_SWING
stw		10, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
li		10, DROP_BALL_PROCEED
lis		9, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(9)

# now r10 must be fixed
# set the ball's position
# load
lis		9, FREE_CAMERA_ABS_COORDS_ADDR@ha
addi	9, 9, FREE_CAMERA_ABS_COORDS_ADDR@l
lswi	3, 9, 12

# store
lwz		9, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
addi	9, 9, BALL_FLYING_STATE_FROM_BASE+BALL_POSITION_FROM_BALL_FLYING_STATE
stswi	3, 9, 12

b		drop_ball_store_status

drop_ball_third_pass:
li		10, GREAT_GAMEPLAY_STATUS_BALL_FLYING
stw		10, GAMEPLAY_STATUS_FROM_GREAT_PLAYER_STATE(31)
li		10, DROP_BALL_INACTIVE
lis		9, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(9)
# note: fall through to drop_ball_store_status

drop_ball_store_status:
lis		9, DROP_BALL_STATUS_ADDR@ha
stw		10, DROP_BALL_STATUS_ADDR@l(9)

# this is needed
cmpwi	10, DROP_BALL_INACTIVE
beq		exit_free_camera_mode
b		free_camera_end

free_camera_check_exit:
# exit if anything not in IGNORE_BUTTON_MASK is pressed
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		0, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
andi.	0, 0, FREE_CAMERA_EXIT_BUTTON_MASK

beq		free_camera_end
# bne		exit_free_camera_mode
# b		free_camera_end

exit_free_camera_mode:
li		3, FREE_CAMERA_INACTIVE

write_free_camera:
lis		9, FREE_CAMERA_STATUS_ADDR@ha
stw		3, FREE_CAMERA_STATUS_ADDR@l(9)

free_camera_end:
