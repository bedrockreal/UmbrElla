#+ c2411fcc 000000..

.include "constants.asm"

# note: scale stored delta by f0

# load f0 := 10
lfs		0, 0x804ec478@l(9)

# load x, z, y
lis		9, FREE_CAMERA_DELTA_ADDR@ha
lfsu	13, FREE_CAMERA_DELTA_ADDR@l(9)
lfsu	12, 0x4(9)
lfsu	11, 0x4(9)

# multiply
fmuls	13, 13, 0
fmuls	12, 12, 0
fmuls	11, 11, 0

# store
stfs	13, 0x148(1)
stfs	12, 0x14c(1)
stfs	11, 0x150(1)
