# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039

# nerf power bar: inject into 0x804742f0
.4byte	0xc24742f0
.4byte	0x00000005

.include "constants.asm"

# note: the adjusted shot charge is stored in r11
# and the player parameters base addr. is already in r9

# only do it if action state == charging
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	3, ACTION_STATE_CHARGING
bne+	end1

li		3, MAX_IMPACT_METER_DRAW_SIZE
cmpw	11, 3
ble-	end1
li		11, 0

# restore replaced instruction
end1:
lis		8, 0x804e

# gecko padding
nop
.4byte	0x00000000

# nerf timing: inject into 0x80475974
.4byte	0xc2475974
.4byte	0x00000005

# still in drawImpactMeterOverlay, make third click thing visible within MAX_IMPACT_METER_DRAW_SIZE frames only

lwz		11, 0x8(30)

# check action state == SWING && r11 < -MAX_IMPACT_METER_DRAW_SIZE
lwz		9, PLAYER_PARAMETERS_FROM_IMPACT_STRUCT(30)
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	3, ACTION_STATE_SWING
cmpwi	cr7, 11, -MAX_IMPACT_METER_DRAW_SIZE
crand	cr0*4+eq, cr0*4+eq, cr7*4+lt
bne		end2

lwz		11, SHOT_CHARGE_NUM_FRAMES_FROM_IMAPCT_STRUCT(30)
neg		11, 11

end2:
# end gecko code
.4byte	0x00000000
.4byte	0xe0000000
.4byte	0x80008000
