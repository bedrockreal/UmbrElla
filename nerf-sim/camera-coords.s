#+ c241233c 000000..

# note: inject into 0x8041233c
# dumps the camera's coordinates into a static place in memory

.include "constants.asm"

lis		9, FREE_CAMERA_ABS_COORDS_ADDR@ha
stfsu	13, FREE_CAMERA_ABS_COORDS_ADDR@l(9)
stfsu	12, 0x4(9)
stfsu	0, 0x4(9)

# restore replaced instruction
stfs	13, 0x158(1)
