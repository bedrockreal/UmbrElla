# drop ball by pressing Z+X

# require current game mode is training
# triggered by pressing Z+X
# 1st pass: gameplayStatus == IDLE == 4 && playerActionState == PANNING == 6
# 2nd pass: gameplayStatus == 6 && playerActionState == 14 (should be true at the frame after 1st pass)

# note:
# 1: the game mode is an integer hard-coded at 0x804fa798 and it equals 3 for training
# 2: the great player state is stored in r31, and gameplayStatus is a word at offset 0x24
# 3: greatGameState->playerParameters is at an offset of 0x4448
# 4: playerParameters->actionState is at an offset of 0x1c4
# 5: the ShotParameters struct is hard-coded at address 0x80518974
# 6: the ball flying state is at *(greatPlayerState + 0x8) + 0xe8
# 7. the ball's position is +0x9c from the ballFlyingState
# 8: the great ball state which stores the character's position is at *(greatPlayerState + 0x8) + 0xb4
# 9: use 0x801d1c20 to store the status

.set	REQUIRE_GREAT_PLAYER_STATE_GAMEPLAY_STATUS,	4
.set	REQUIRE_PLAYER_PARAMETERS_ACTION_STATE,		5
.set	GAME_MODE_ADDR,								0x804fa798
.set	REQUIRE_GAME_MODE,							3
.set	GAMEPLAY_STATUS_FROM_GREAT_PLAYER_STATE,	0x24
.set	PLAYER_PARAMETERS_FROM_GREAT_PLAYER_STATE,	0x4448
.set	ACTION_STATE_FROM_PLAYER_PARAMETERS,		0x1c4
.set	BUTTON_HOLD_FROM_PLAYER_PARAMETERS,			0x100
.set	BUTTON_PRESS_FROM_PLAYER_PARAMETERS,		0x104
# 0x102 is a copy of 0x100, the button hold mask
# 0x104 is the press mask
# the half word at 0x104 activates at only the frame the button is pressed (not activated when holding)

.set	MODIFIER_MASK,			0x10 # Z
.set	ACTIVATE_PRESS_MASK,	0x400 # X
.set	EXEC_PRESS_MASK,		0x400 # X
# .set	EXEC_BUTTON_MASK_FIRST,	0x10 # Z
# .set	IGNORE_BUTTON_MASK,		0x01f # Z + D-pad
.set	EXIT_BUTTON_MASK,		0xffe0 # complement of above
.set	IMPACT_WAIT_ADDR,		0x8053738c
.set	INDICATOR_ADDR,			0x801d1c20
.set	DROP_BALL_PROCEED,		-0x100
.set	FREE_CAMERA,			1
.set	DROP_BALL_START,		2
.set	DROP_BALL_END,			0
.set	SHOT_PARAMTERS_ADDR,	0x80518974
.set	LAUNCH_VELO_OFFSET,		0x48
.set	NATURAL_SPIN_OFFSET,	0x50
.set	ACTION_STATE_IDLE,		5
.set	ACTION_STATE_PANNING,	6
.set	GREAT_BALL_STATE_FROM_GREAT_PLAYER_STATE,	0x18
.set	GREAT_PLAYER_STATE_FROM_PLAYER_PARAMETERS,	0x25c
.set	BALL_FLYING_STATE_BASE_FROM_GREAT_PLAYER_STATE,	0x8
.set	BALL_FLYING_STATE_FROM_BASE,	0xe8
.set	POSITION_FROM_BALL_FLYING_STATE,	0x9c
