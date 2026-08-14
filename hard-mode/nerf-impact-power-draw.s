#+ 20416dbc 3f608039
#+ c24742f0 000000..

.include "constants.asm"

# note: the adjusted shot charge is stored in r11
# and the player parameters base addr. is already in r9

# only do it if action state == charging
lwz		3, ACTION_STATE_FROM_PLAYER_PARAMETERS(9)
cmpwi	3, ACTION_STATE_CHARGING
bne+	end

li		3, MAX_IMPACT_METER_DRAW_SIZE
cmpw	11, 3
ble-	end
li		11, 0

# restore replaced instruction
end:
lis		8, 0x804e
