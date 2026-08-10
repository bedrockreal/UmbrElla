#+ 20416dbc 3f608039
#+ c2424fb4 000000..

# note: inject into loadShot @ 0x80424fb4
# if mode is not training && state is not 2D view,
# then display only the first SIM_LINE_VISIBLE_FRAMES of the sim line

.include "constants.asm"

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
