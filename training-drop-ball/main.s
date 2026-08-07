# inject into 0x80424fb4

.include "constants.asm"

main:
# check for training mode
lis		9, GAME_MODE_ADDR@ha
lwz		0, GAME_MODE_ADDR@l(9)
cmpwi	0, REQUIRE_GAME_MODE
bne		end

# check for current state
lis		9, INDICATOR_ADDR@ha
lwz		0, INDICATOR_ADDR@l(9)
cmpwi	0, DROP_BALL_PROCEED
cmpwi	cr7, 0, DROP_BALL_START
cmpwi	cr6, 0, FREE_CAMERA
beq		drop_ball_third_pass
beq		cr7, drop_ball_first_pass
beq		cr6, free_camera_mode

activate_check:
# r0 = greatGameState->gameplayStatus, r10 = playerParameters->actionState
lwz		0, GAMEPLAY_STATUS_FROM_GREAT_PLAYER_STATE(31)
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		10, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

# check r0 == 4 && r10 == 6
cmpwi	cr7, 0, REQUIRE_GREAT_PLAYER_STATE_GAMEPLAY_STATUS
cmpwi	cr0, 10, ACTION_STATE_IDLE
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end

# check Z hold + X press
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	10, MODIFIER_MASK+ACTIVATE_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, ACTIVATE_PRESS_MASK
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end

# enter free camera mode
li		0, ACTION_STATE_PANNING
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
li		0, FREE_CAMERA
b		set_indicator_addr_and_end

exit_free_camera_mode:
li		0, ACTION_STATE_IDLE
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

# TODO: restore ball's position
# exit
li		0, EXIT
b		set_indicator_addr_and_end

free_camera_mode:
# Z hold + X press -> drop ball
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	10, MODIFIER_MASK+EXEC_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, EXEC_PRESS_MASK
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
beq		drop_ball_first_pass

# otherwise, exit if anything not in IGNORE_BUTTON_MASK is pressed
andi.	10, 10, EXIT_BUTTON_MASK
bne		exit_free_camera_mode
b		end

drop_ball_first_pass:
# set actionState := 12
li		10, 12
stw		10, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

# set IMPACT_WAIT_ADDR to a large negative number
li		0, DROP_BALL_PROCEED
lis		9, IMPACT_WAIT_ADDR@ha
stw		0, IMPACT_WAIT_ADDR@l(9)

# mark the drop_ball_first_pass as completed
b		set_indicator_addr_and_end

drop_ball_third_pass:
# set greatGameState->gameplayStatus = 7
li		0, 7
stw		0, 0X24(31)

# set_exit_state:
# reset IMPACT_WAIT_ADDR := 0
li		0, EXIT
lis		9, IMPACT_WAIT_ADDR@ha
stw		0, IMPACT_WAIT_ADDR@l(9)

# mark drop_ball_third_pass as completed
set_indicator_addr_and_end:
lis		9, INDICATOR_ADDR@ha
stw		0, INDICATOR_ADDR@l(9)

# restore replaced instruction
end:
li		3, 0xad
