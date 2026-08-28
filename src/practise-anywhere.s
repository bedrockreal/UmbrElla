# note: the game crashes upon entering training mode if you apply this code alongside other codes on a real Wii (perhaps also GameCube).

# check for the right file
.long	0x20416dbc
.long	0x3f608039

# note: split free camera driver code apart

.include "constants.asm"

# set NO_STANDALONE for all sub-codes included by this file
.set	NO_STANDALONE, 1

.include "practise-anywhere/free-camera.s"

# always: don't move impact marker with Z + analogue stick
.long	0x04410cec
li		0, 0

# add the code that modifies shot parameters
.include "practise-anywhere/drop-ball-mod-params.s"

# add the code to load camera delta for projection
# the code to check for free-camera is already included.
.include "practise-anywhere/camera-delta.s"

# dumps the camera's coordinates into a static place in memory: always do that
.include "practise-anywhere/camera-coords.s"

# on c stick up/down, do not move along sim line if free-camera is active; instead, add to dx @ for projection
.include "practise-anywhere/camera-front.s"

# that's it
.long	0xe0000000
.long	0x80008000
