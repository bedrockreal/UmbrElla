#+ c241293c 000000..

.include "constants.asm"

lis		9, FREE_CAMERA_COORDS_ADDR@ha
lfsu	11, FREE_CAMERA_COORDS_ADDR@l(9)
fadds	11, 11, 0
stfs	11, 0(9)
fsubs	0, 0, 0
fmr		31, 0
