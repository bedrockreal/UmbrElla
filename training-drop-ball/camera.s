# inject into 0x8041233c

.include "constants.asm"

# requires playerParameters->actionState == 6
# the pointer to playerParameters is at r31
# the camera's x, z and y coordinates are currently in f13, f12 and f0

# check for free camera mode
lis		9, INDICATOR_ADDR@ha
lwz		0, INDICATOR_ADDR@l(9)
cmpwi	0, FREE_CAMERA
bne		end

# set ball position to camera's
lwz		9, GREAT_PLAYER_STATE_FROM_PLAYER_PARAMETERS(31)
lwz		9, BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE(9)
stfsu	13, BALL_FLYING_STATE_FROM_BASE+POSITION_FROM_BALL_FLYING_STATE(9)
stfsu	12, 4(9)
stfsu	0, 4(9)

# restore replaced instruction
end:
stfs	f13, 0x158(1)
