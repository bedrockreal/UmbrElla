#+ c2425da8 000000..

# note: patch 'bl updateSimLine' to inject custom code
# before the call, r3-r6 must be fixed

.include "constants.asm"

# check free camera
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		8, FREE_CAMERA_STATUS_ADDR@l(9)
addic.	8, 8, -FREE_CAMERA_ACTIVE
stw		8, PLAYER_POSITION_DUMP_STATUS_ADDR@l(9)
bne		call

# dump the player position
lswi	8, 4, 12
lis		11, PLAYER_POSITION_DUMP_ADDR@ha
addi	11, 11, PLAYER_POSITION_DUMP_ADDR@l
stswi	8, 11, 12

# modify the player position
addi	11, 11, FREE_CAMERA_ABS_COORDS_ADDR-PLAYER_POSITION_DUMP_ADDR
lswi	8, 11, 12
stswi	8, 4, 12

call:
lis		9, UPDATE_SIM_LINE_ADDR@ha
addi	9, 9, UPDATE_SIM_LINE_ADDR@l
mtctr	9
bctrl

# check if we need to restore player position
lis		9, PLAYER_POSITION_DUMP_STATUS_ADDR@ha
lwz		8, PLAYER_POSITION_DUMP_STATUS_ADDR@l(9)
cmpwi	8, 0
bne		end

# restore position
# note: the great player state is at r31
addi	9, 9, PLAYER_POSITION_DUMP_ADDR@l
lswi	3, 9, 12
lwz		9, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
addi	9, 9, PLAYER_POSITION_FROM_BASE
stswi	3, 9, 12

end:
