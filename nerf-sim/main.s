# 20416dbc 3f608039
# c2424fb4 ........

# note: inject into loadShot @ 0x80424fb4
# if mode is not training && state is not 2D view,
# then display only the first SIM_LINE_VISIBLE_FRAMES of the sim line

# let's combine the free_camera_mode

.include "constants.asm"

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
lis		9, FREE_CAMERA_COORDS_ADDR@ha
addi	9, 9, FREE_CAMERA_COORDS_ADDR@l
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
lis		9, FREE_CAMERA_COORDS_ADDR@ha
addi	9, 9, FREE_CAMERA_COORDS_ADDR@l
lfs		0, 0x8(9) # y
fadds	0, 13, 0
stfs	0, 0x8(9)
lfs		0, 0x4(9) # z
fadds	0, 12, 0
stfs	0, 0x4(9)

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

modify_sim:
# check if action state is not 2d view
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
addic.	3, 3, -ACTION_STATE_2D_VIEW
li		3, NERF_SIM_NO_HEIGHT_MAP
beq		write_nerf_sim

# check if we are not putting
lwz		3, CLUB_ID_FROM_PLAYER_PARAMETERS(9)
addic.	3, 3, -CLUB_ID_PUTTER
beq		write_nerf_sim

# check for practice mode
lis		9, GAME_MODE_ADDR@ha
lwz		3, GAME_MODE_ADDR@l(9)
addic.	3, 3, -GAME_MODE_PRACTICE
beq		write_nerf_sim

# set status = 1
li		3, NERF_SIM_NO_STAR

write_nerf_sim:
lis		9, NERF_SIM_STATUS_ADDR@ha
stw		3, NERF_SIM_STATUS_ADDR@l(9)

end:
li		3, 0xad
