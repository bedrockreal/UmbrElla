# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039

.include "constants.asm"

.set	SWEET_SPOT_SIZE_ARR_ADDR,	0x804ec700

# inject 0x38 bytes into 0x80417888
.4byte	0x06417888
.4byte	0x00000038

# note: r3 contains the impact stat just returned
# and r31 contains shotDifficulty

lis		9, SWEET_SPOT_SIZE_ARR_ADDR@ha
addi	9, 9, SWEET_SPOT_SIZE_ARR_ADDR@l

subfic	3, 3, 10
mulli	3, 3, 5
add		3, 3, 31

add		3, 3, 9
lbz		9, -1(3)

# now r9 contains the raw sweet spot size from memory
# load shotMode from memory

lwz		4, SHOT_MODE_FROM_PLAYER_PARAMETERS(29)
addi	3, 9, -1
add		9, 3, 4

# pad: add 4 nops
nop
nop
nop
nop

.4byte	0xe0000000
.4byte	0x80008000
