#+ c2411fcc 000000..

.include "constants.asm"

lis		9, FREE_CAMERA_COORDS_ADDR@ha
lfsu	12, FREE_CAMERA_COORDS_ADDR@l(9)
# fmuls	12, 12, 0
stfs	12, 0x148(1)
lfsu	12, 0x4(9)
# fmuls	12, 12, 0
stfs	12, 0x14c(1)
lfsu	12, 0x4(9)
# fmuls	12, 12, 0
stfs	12, 0x150(1)
