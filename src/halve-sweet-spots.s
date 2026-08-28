.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.long	0x20416dbc
.long	0x3f608039
.endif

# save the sweet spot delta somewhere
.long	0xc2417874
.long	3

# the original instr.
add		3, 3, 9

# r9 is now free
lwz		4, SHOT_MODE_FROM_PLAYER_PARAMETERS(29)
subi	4, 4, 1
lis		9, SWEET_SPOT_DELTA_SAVE_ADDR@ha
stw		4, SWEET_SPOT_DELTA_SAVE_ADDR@l(9)

.zero	4

# load the delta and add to ret
.long	0x064178b4
.long	0xc

lis		9, SWEET_SPOT_DELTA_SAVE_ADDR@ha
lwz		9, SWEET_SPOT_DELTA_SAVE_ADDR@l(9)
add		9, 9, 3
.zero	4

.if		(NO_STANDALONE != 1)
.long	0xe0000000
.long	0x80008000
.endif
