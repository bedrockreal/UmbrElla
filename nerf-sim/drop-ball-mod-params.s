#+ c2425c34 000000..

# note: inject into 0x80425d90
# modifies the sim line's parameters

.include "constants.asm"

# check for free camera mode + drop ball proceed
lis		3, FREE_CAMERA_STATUS_ADDR@ha
lwz		4, FREE_CAMERA_STATUS_ADDR@l(3)
cmpwi	4, FREE_CAMERA_ACTIVE
lis		3, DROP_BALL_STATUS_ADDR@ha
lwz		10, DROP_BALL_STATUS_ADDR@l(3)
cmpwi	cr7, 10, DROP_BALL_PROCEED
crand	cr0*4+eq, cr0*4+eq, cr7*4+eq
bne		end

# this is drop_ball_second_pass

lis		3, SHOT_PARAMETERS_ADDR@ha
addi	3, 3, SHOT_PARAMETERS_ADDR@l

# set velocity and spin = 0
li		4, 0
stw		4, LAUNCH_VELO_FROM_SHOT_PARAMETERS(3)
stw		4, NATURAL_SPIN_FROM_SHOT_PARAMETERS(3)

end:
lwz		0, 0xb14(30)
