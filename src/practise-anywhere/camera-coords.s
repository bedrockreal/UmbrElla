.if		(NO_STANDALONE != 1)
# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

.include "constants.asm"

# note: inject into 0x8041233c
# dumps the camera's coordinates into a static place in memory
.long	0xc241233c
.long	0x00000003


lis		9, FREE_CAMERA_ABS_COORDS_ADDR@ha
stfsu	13, FREE_CAMERA_ABS_COORDS_ADDR@l(9)
stfsu	12, 0x4(9)
stfsu	0, 0x4(9)

# restore replaced instruction
stfs	13, 0x158(1)

# gecko inject end pad
.zero	4

.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
