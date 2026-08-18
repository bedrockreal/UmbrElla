.if		(NO_STANDALONE != 1)
# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

.include "constants.asm"

# inject into 0x80411fcc
.long	0xc2411fcc
.long	0x00000006

# note: scale stored delta by f0
# note: r9, r0 and r10 are free. r3-r5 are already loaded

# load f0 := 10
lfs		0, CONST_10_ADDR@l(9)

# set up addresses and CTR
lis		9, FREE_CAMERA_DELTA_ADDR@h
ori		9, 9, FREE_CAMERA_DELTA_ADDR@l-0x4
li		10, 3
mtctr	10
addi	10, 1, 0x144

loop:
lfsu	13, 0x4(9)
fmuls	13, 13, 0
stfsu	13, 0x4(10)
bdnz+	loop

# gecko inject end pad
nop
.zero	4

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
