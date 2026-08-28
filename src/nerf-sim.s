.if		(NO_STANDALONE != 1)
.include "constants.asm"

# note: given that free-camera/practise-anywhere doesn't work on Nintendont, let's keep the landing star and height map visible.

# Overwrite debug strings, if we haven't
# note: reserve 0x100 bytes from 0x801d1c20

.long	0x201d1c24
.long	0x6462616e
.long	0x001d1c20
.long	0x00ff0000

# check for the right file
.long	0x20416dbd
.long	0x3f608039
.endif

# note: inject into loadShot @ 0x80424fb4
.long	0xc2424fb4
.long	6

# if state is not 2D view, then
# 1. display only the first SIM_LINE_NERF_VISIBLE_FRAMES of the sim line
# # 2. don't draw height map and star

# TODO: maybe special handle if mode == practice?

# the main code:
.set	SIM_LINE_DEFAULT_VISIBLE_FRAMES,	0x707
.set	SIM_LINE_NERF_VISIBLE_FRAMES,		0x8

modify_sim:
# check if action state is neither 2d nor green view
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, ACTION_STATE_2D_VIEW
beq-	write_nerf_sim

# cmpwi	cr7, 3, ACTION_STATE_GREEN_VIEW

# also check if we're putting: if so, nerf sim is inactive
lwz		3, CLUB_ID_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, CLUB_ID_PUTTER
# cror	cr0*4+eq, cr0*4+eq, cr7*4+eq
# cror	cr0*4+eq, cr0*4+eq, cr6*4+eq
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

# # endif, then copy 16 bytes from 0x804170d4 to 0x804173a4
# .long	0xe2000001
# .long	0x00000000

# gr0 := 0x804173a4
.long	0x80000000
.long	0x804173a4

# copy
.long	0x8c0010f0
.long	0x004170d4

# force sim line mode = 7
.long	0x04425d64
li		0, SIM_LINE_MODE_NO_BOUNCE

# # always no height map
# .long	0x044274d4
# nop


# if nerf-sim mode != 1, restore
.long	0x221d1c28
.long	0x00000001

.long	0x044170d4
cmpwi	0, SIM_LINE_DEFAULT_VISIBLE_FRAMES

.long	0x044170e0
li		28, SIM_LINE_DEFAULT_VISIBLE_FRAMES

# restore height map
# .long	0x044274d4
# .long	0x480247bd

# and star
# .long	0x04432b00
# .long	0x4800126d

# and if that's 1,
.long	0x201d1c29
.long	0x00000001

# set sim line visible frames
.long	0x044170d4
cmpwi	0, SIM_LINE_NERF_VISIBLE_FRAMES

.long	0x044170e0
li		28, SIM_LINE_NERF_VISIBLE_FRAMES

# no height map
# .long	0x044274d4
# nop

# and star
# .long	0x04432b00
# nop

# that's it
.if		(NO_STANDALONE != 1)
.long	0xe0000000
.long	0x80008000
.endif
