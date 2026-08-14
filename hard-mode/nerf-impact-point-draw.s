# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039

# inject asm into 0x8042fa90
.4byte	0xc242fa90
.4byte	0x00000004

# hides the impact point when action_state == SWING/IMPACT == 12
# if action state == SWING, skip the impact point == impact marker thing, jump to 0x8042fba0,
# 0x8042fc38: 
# note: the playerParameters is in r3

.include "constants.asm"

lwz		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(3)
cmpwi	0, ACTION_STATE_SWING
lis		0, 8000
bne		restore
b		first_pass_end

restore:
# restore replaced instruction
lwz		0, 0x64(25)

first_pass_end:

# end inject asm, pad for gecko
nop
.4byte	0x00000000

# inject asm into 0x8042fcf8
.4byte	0xc242fcf8
.4byte	0x00000005

lwz		9, PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE(22)
lwz		4, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	4, ACTION_STATE_SWING
bne		second_pass_end

# 'return;': branch to 0x8042fd54
lis		9, 0x8042
ori		9, 9, 0xfd54
mtctr	9
bctr

second_pass_end:
lis		9, 0x804f

# end gecko code
.4byte	0x00000000
.4byte	0xe0000000
.4byte	0x80008000
