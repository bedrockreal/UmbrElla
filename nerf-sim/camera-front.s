.include "constants.asm"

lis		9, FREE_CAMERA_COORDS_ADDR@ha
lfsu	30, FREE_CAMERA_COORDS_ADDR@l(9)
fadds	30, 30, 31
stfs	30, 0(9)
