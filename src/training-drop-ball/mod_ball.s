# inject into 0x80425c34

.include "constants.asm"

# between the 1st and 2nd pass, modify ball parameters
# check for this exact moment
lis		9, INDICATOR_ADDR@ha
lwz		0, INDICATOR_ADDR@l(9)
cmpwi	0, DROP_BALL_PROCEED
bne		end

second_pass:
lis		9, SHOT_PARAMTERS_ADDR@ha
addi	9, 9, SHOT_PARAMTERS_ADDR@l
li		0, 0
stw		0, LAUNCH_VELO_OFFSET(9)
stw		0, NATURAL_SPIN_OFFSET(9)

# restore replaced instruction
end:
lwz		0, 0xb14(30)
