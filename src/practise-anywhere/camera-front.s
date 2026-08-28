.if		(NO_STANDALONE != 1)
# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

.include "constants.asm"

.long	0xc241293c
.long	6

# check for free-camera
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		11, FREE_CAMERA_STATUS_ADDR@l(9)
cmpwi	11, FREE_CAMERA_ACTIVE
bne		end_camera_front

lfsu	11, FREE_CAMERA_DELTA_ADDR@l(9)
fadds	11, 11, 0
stfs	11, 0(9)
fsubs	0, 0, 0
fmr		31, 0

end_camera_front:
# the original instruction
# note: r9 must equal 0x804f0000
lis		9, 0x804f
fabs	0, 0
.zero	4

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
