# note: due to how big this gecko code is, the game sometimes crashes when you apply this code alongside other codes on a real Wii (perhaps also GameCube).
# this may be an issue with the gecko code size.

# Overwrite debug strings, if we haven't
# note: reserve 0x100 bytes from 0x801d1c20

.4byte	0x201d1c24
.4byte	0x6462616e
.4byte	0x001d1c20
.4byte	0x00ff0000

# check for the right file
.4byte	0x20416dbd
.4byte	0x3f608039

# note: split free camera driver code apart

.include "constants.asm"

# set NO_STANDALONE for all sub-codes included by this file
.set	NO_STANDALONE, 1

# inject the main code
.long	0xc2424fb0
.long	40

# note: r5 - r7 are free

# restore replaced instruction
stw		0, 0x1c4(1)

free_camera_start:
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		0, FREE_CAMERA_STATUS_ADDR@l(9)
cmpwi	0, FREE_CAMERA_ACTIVE
beq		free_camera_mode

free_camera_activate_check:
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
subic.	3, 3, ACTION_STATE_IDLE
bne		free_camera_end

# check Z hold + X press
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
subic.	10, 10, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		free_camera_end

# enter free camera mode
li		0, ACTION_STATE_PANNING
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)

# clear FREE_CAMERA_DELTA_ADDR
# hack: r10 == 0 if we reach here
lis		9, FREE_CAMERA_DELTA_ADDR@ha
stwu	10, FREE_CAMERA_DELTA_ADDR@l(9)
stwu	10, 4(9)
stwu	10, 4(9)

li		3, FREE_CAMERA_ACTIVE
b		write_free_camera

free_camera_mode:
# load analogue stick using paired singles instructions
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
psq_l	13, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS(9), 0, 0
# ps_sub	12, 13, 13
# psq_st	12, ANALOGUE_STICK_FROM_PLAYER_PARAMETERS(9), 0, 0

# add analogue delta to free camera coordinates
lis		9, FREE_CAMERA_DELTA_ADDR@ha
addi	9, 9, FREE_CAMERA_DELTA_ADDR@l

# swap the floats in f13 first (y, z) -> (z, y), then add and store
ps_merge10		13, 13, 13
psq_l	12, 0x4(9), 0, 0
ps_add	12, 12, 13
psq_st	12, 0x4(9), 0, 0

check_drop_ball:
# check if already in drop ball state
lis		9, DROP_BALL_STATUS_ADDR@ha
lwz		10, DROP_BALL_STATUS_ADDR@l(9)
cmpwi	10, DROP_BALL_PROCEED
beq		drop_ball_third_pass

# press the free camera activate combo to drop ball in practice mode
lis		9, GAME_MODE_ADDR@ha
lwz		10, GAME_MODE_ADDR@l(9)
cmpwi	10, GAME_MODE_PRACTICE
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		10, BUTTON_HOLD_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr6, 10, MODIFIER_MASK+FREE_CAMERA_ACTIVATE_PRESS_MASK
lhz		10, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
cmpwi	cr7, 10, FREE_CAMERA_ACTIVATE_PRESS_MASK
crand	cr6*4+eq, cr6*4+eq, cr7*4+eq
crand	cr0*4+eq, cr6*4+eq, cr0*4+eq
bne		free_camera_check_exit

# in drop ball state now

drop_ball_first_pass:
li		10, ACTION_STATE_SWING
stw		10, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
li		10, DROP_BALL_PROCEED
lis		9, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(9)

# now r10 must be fixed
# set the ball's position
# load
lis		9, FREE_CAMERA_ABS_COORDS_ADDR@ha
addi	9, 9, FREE_CAMERA_ABS_COORDS_ADDR@l
lswi	3, 9, 12

# store
lwz		9, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
addi	9, 9, BALL_FLYING_STATE_FROM_BASE+BALL_POSITION_FROM_BALL_FLYING_STATE
stswi	3, 9, 12

b		drop_ball_store_status

drop_ball_third_pass:
li		10, GREAT_GAMEPLAY_STATUS_BALL_FLYING
stw		10, GAMEPLAY_STATUS_FROM_GREAT_PLAYER_STATE(31)
# also increment stroke count
lwz		9, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(31)
lbz		10, HOLE_STROKE_COUNT_FROM_BASE(9)
addi	10, 10, 1
stb		10, HOLE_STROKE_COUNT_FROM_BASE(9)

# done -> set status := inactive
li		10, DROP_BALL_INACTIVE
lis		9, DROP_BALL_IMPACT_WAIT_ADDR@ha
stw		10, DROP_BALL_IMPACT_WAIT_ADDR@l(9)

# note: fall through to drop_ball_store_status

drop_ball_store_status:
lis		9, DROP_BALL_STATUS_ADDR@ha
stw		10, DROP_BALL_STATUS_ADDR@l(9)

# this is needed
cmpwi	10, DROP_BALL_INACTIVE
beq		exit_free_camera_mode
b		free_camera_end

free_camera_check_exit:
# exit if anything not in IGNORE_BUTTON_MASK is pressed
lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(31)
lhz		0, BUTTON_PRESS_FROM_PLAYER_PARAMETERS(9)
andi.	0, 0, FREE_CAMERA_EXIT_BUTTON_MASK

beq		free_camera_end

exit_free_camera_mode:
li		3, FREE_CAMERA_INACTIVE

write_free_camera:
lis		9, FREE_CAMERA_STATUS_ADDR@ha
stw		3, FREE_CAMERA_STATUS_ADDR@l(9)

free_camera_end:
.zero	4

# always: don't move impact marker with Z + analogue stick
.long	0x04410cec
li		0, 0

# add the code that modifies shot parameters
.include "drop-ball-mod-params.s"

# add the code to load camera delta for projection
# the code to check for free-camera is already included.
.include "camera-delta.s"

# dumps the camera's coordinates into a static place in memory: always do that
.include "camera-coords.s"

# on c stick up/down, do not move along sim line if free-camera is active; instead, add to delta x
.include "camera-front.s"

# modify comparison at 0x80411f5c (compare 0.98 and cameraSimLine%)
.long	0xc2411f50
.long	3

# the hack: modify r9 such that f31 := (free-camera ? -4 : 0.98)
# load free-camera
lis		9, FREE_CAMERA_STATUS_ADDR@ha
lwz		11, FREE_CAMERA_STATUS_ADDR@l(9)

# the original instr.
lis		9, 0x804f

# set r11 = (free-camera ? 60 : 0), r9 -= r11
mulli	11, 11, 20
subf	9, 11, 9

.zero	4

# original 0x80411f60: if f0 <= f31 (f31 == 0.98), don't project delta

# that's it
.4byte	0xe0000000
.4byte	0x80008000
