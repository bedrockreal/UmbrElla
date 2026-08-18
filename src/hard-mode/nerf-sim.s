# Overwrite debug strings, if we haven't
# note: reserve 0x100 bytes from 0x801d1c20

.4byte	0x201d1c24
.4byte	0x6462616e
.4byte	0x001d1c20
.4byte	0x00ff0000

# check for the right file
.4byte	0x20416dbd
.4byte	0x3f608039

# note: inject into loadShot @ 0x80424fb4
.4byte	0xc2424fb4
.4byte	0x00000006

# if mode is not training && state is not 2D view,
# then display only the first SIM_LINE_VISIBLE_FRAMES of the sim line

.include "constants.asm"

# the main code:
modify_sim:
# check if action state is not 2d view
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, ACTION_STATE_2D_VIEW
beq-	write_nerf_sim

# check if we are not putting
lwz		3, CLUB_ID_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, CLUB_ID_PUTTER
beq-	write_nerf_sim

# partial sim line
li		3, NERF_SIM_NO_STAR

# check for practice mode
# lis		9, GAME_MODE_ADDR@ha
# lwz		3, GAME_MODE_ADDR@l(9)
# addic.	3, 3, -GAME_MODE_PRACTICE
# # default: partial sim line
# 
# # if not in training, force this mode
# bne		write_nerf_sim
# 
# # in practice: make sim line visible by Z + A hold
# lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
# lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
# andi.	10, 10, PRACTICE_RESTORE_SIM_HOLD_MASK
# cmpwi	10, PRACTICE_RESTORE_SIM_HOLD_MASK
# bne		write_nerf_sim
# li		3, NERF_SIM_INACTIVE

write_nerf_sim:
lis		9, NERF_SIM_STATUS_ADDR@ha
stw		3, NERF_SIM_STATUS_ADDR@l(9)

end:
li		3, 0xad

# gecko inject end
.zero	4

# if nerf-sim mode != 1, restore
.4byte	0x221d1c28
.4byte	0x00000001

.4byte	0x044170d4
cmpwi	0, SIM_LINE_DEFAULT_VISIBLE_FRAMES

.4byte	0x044170e0
li		28, SIM_LINE_DEFAULT_VISIBLE_FRAMES

# restore height map
.4byte	0x044274d4
.4byte	0x480247bd

# .ifdef NO_LANDING_STAR
# .4byte	0x04432b00
# .4byte	0x4800126d
# .endif

# and if that's 1,
.4byte	0x201d1c29
.4byte	0x00000001

# set sim line visible frames
.4byte	0x044170d4
cmpwi	0, SIM_LINE_VISIBLE_FRAMES

.4byte	0x044170e0
li		28, SIM_LINE_VISIBLE_FRAMES

# no height map
.4byte	0x044274d4
nop

# don't draw landing star
# .ifdef		NO_LANDING_STAR
# .4byte	0x04432b00
# nop
# .endif

# endif, then copy 16 bytes from 0x804170d4 to 0x804173a4
.long	0xe2000001
.long	0x00000000

# gr0 := 0x804173a4
.long	0x80000000
.long	0x804173a4

# copy
.long	0x8c0010f0
.long	0x004170d4

# force sim line mode = 7
.long	0x04425d64
li		0, SIM_LINE_MODE_TRAINING

# draw height map <=> nerf-sim mode != 2
# .4byte	0x221d1c29
# .4byte	0x00000002
# 
# .4byte	0x044274d4
# .4byte	0x480247bd
# 
# .4byte	0x201d1c29
# .4byte	0x00000002
# 
# .4byte	0x044274d4
# nop

# that's it
.4byte	0xe0000000
.4byte	0x80008000
