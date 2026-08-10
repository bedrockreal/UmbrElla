#+ c2411fcc 000000..

.include "constants.asm"

# note: scale stored delta by 2

# x
lis		9, FREE_CAMERA_DELTA_ADDR@ha
lfsu	12, FREE_CAMERA_DELTA_ADDR@l(9)
fadds	12, 12, 12
stfs	12, 0x148(1)

# z
lfsu	12, 0x4(9)
fadds	12, 12, 12
stfs	12, 0x14c(1)

# y
lfsu	12, 0x4(9)
fadds	12, 12, 12
stfs	12, 0x150(1)
