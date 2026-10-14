.ifndef	MOD_LANDING
.set	MOD_LANDING, 1

.if		(NO_STANDALONE != 1)
.include "constants.asm"

# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

# inject into 0x80416bb4, before call to updateBallPosition
.long	0xc2416bb4
.long	9

# 11/10/2026: In updateSimLine, set custom ball position after the sim line's visible frames. Also set velocity to (0, 0, {very big -ve}).

# note: nerf-sim-with-height-map should be included

.include "constants.asm"

# restore: r30 is the simulation frame to be computed
addi	30, 30, 1

# require 1. free camera, and 2. curFrame == nerf (do this once only)

# check free camera
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		8, FREE_CAMERA_STATUS_ADDR@l(9)
addic.	8, 8, -FREE_CAMERA_ACTIVE
cmpwi	cr7, 30, SIM_LINE_NERF_VISIBLE_FRAMES
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end_mod_landing

# mod landing: r3 is the sim ball state where
# position: offset = 0x9c
# velocity: offset = 0x50
# note: if code reaches here, r8 == 0

# set position:
lis		9, FREE_CAMERA_ABS_COORDS_ADDR@ha
addi	9, 9, FREE_CAMERA_ABS_COORDS_ADDR@l
lswi	4, 9, 12
addi	7, 3, BALL_POSITION_FROM_BALL_FLYING_STATE
stswi	4, 7, 12

# set velocity:  = (x=0, z=0xc0800000 (-4.0), y=0)
# 0xc300 (-128.0) is an overkill and causes issues
lis		7, 0xc000
stw		8, BALL_VELOCITY_FROM_BALL_FLYING_STATE(3)
stw		7, BALL_VELOCITY_FROM_BALL_FLYING_STATE+4(3)
stw		8, BALL_VELOCITY_FROM_BALL_FLYING_STATE+8(3)

# TODO: maybe reset spin := 0

end_mod_landing:
nop
.long	0

# now, force sim line update by disabling early return
.long	0x04416620
nop

# TODO: fix issue with arrows, by delaying 

.if		(NO_STANDALONE != 1)
.long	0xe0000000
.long	0x80008000
.endif

.endif
