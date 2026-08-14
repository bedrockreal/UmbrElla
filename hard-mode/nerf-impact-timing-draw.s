# 20416dbc 3f608039
#+ c2475974 000000..

.include "constants.asm"

# still in drawImpactMeterOverlay, make third click thing visible within MAX_IMPACT_METER_DRAW_SIZE frames only

lwz		11, 0x8(30)

# check action state == SWING && r11 < -MAX_IMPACT_METER_DRAW_SIZE
lwz		9, PLAYER_PARAMETERS_FROM_IMPACT_STRUCT(30)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	3, ACTION_STATE_SWING
cmpwi	cr7, 11, -MAX_IMPACT_METER_DRAW_SIZE
crand	cr0*4+eq, cr0*4+eq, cr7*4+lt
bne		end

lwz		11, SHOT_CHARGE_NUM_FRAMES_FROM_IMAPCT_STRUCT(30)
neg		11, 11

end:
