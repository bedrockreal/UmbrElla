.if		(NO_STANDALONE != 1)
# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

#+ c241293c 000000..

.include "constants.asm"

.long	0xc241293c
.long	0x00000004

lis		9, FREE_CAMERA_DELTA_ADDR@ha
lfsu	11, FREE_CAMERA_DELTA_ADDR@l(9)
fadds	11, 11, 0
stfs	11, 0(9)
fsubs	0, 0, 0
fmr		31, 0

nop
.zero	4
.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
