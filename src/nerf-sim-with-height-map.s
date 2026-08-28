.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.long	0x20416dbc
.long	0x3f608039
.endif

# if state is not 2D view, then
# 1. display only the first SIM_LINE_NERF_VISIBLE_FRAMES of the sim line
# # 2. don't draw height map and star

# TODO: maybe special handle if mode == practice?

.set	SIM_LINE_DEFAULT_VISIBLE_FRAMES,	0x707
.set	SIM_LINE_NERF_VISIBLE_FRAMES,		0x8

# the main code:
# note: inject into loadShot @ 0x80424fb4
.long	0xc2424fb4
.long	5

# set r3 := (actionState == 2D_VIEW ? 0 : 1)
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
xori	3, 3, ACTION_STATE_2D_VIEW
subfic	11, 3, 0
adde	3, 11, 3

# now r3 := (actionState == 2D_VIEW ? 1 : 0). negate by xor-ing with 1
xori	3, 3, 1

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
.long	1

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
.long	1

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
