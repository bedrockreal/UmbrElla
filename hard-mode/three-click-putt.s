# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039

.include "constants.asm"

# patch parameters set on first press when putting
.4byte	0x06413df8
.4byte	0x00000018
li		0, ACTION_STATE_SWING
li		3, 0x2a3
stw		0, ACTION_STATE_FROM_PLAYER_PARAMETERS(31)
nop
li		0, PUTT_IMPACT_CAP_FRAMES
stw		0, SWEETSPOT_SIZE_FROM_IMPACT_STRUCT(9)

# write active club id to static addr, and always draw impact timing slider
.4byte	0x064758f8
.4byte	0x00000008

lis		9, ACTIVE_PLAYER_CLUB_ID_SAVE_ADDR@ha
stw		0, ACTIVE_PLAYER_CLUB_ID_SAVE_ADDR@l(9)

# if we're putting...

.4byte	0x201d1c60
.4byte	0x0000000d

# no 'nice shot': branch from 0x8041406c to 0x804141dc
.4byte	0xc641406c
.4byte	0x804141dc

# force manual putt: already done

# force 1 button press only for 3rd click
.4byte	0x04414204
cmpwi	11, 0

# no set meter display mode := 4 on third click
.4byte	0x044142e8
nop

# no mishit when putting: patch 0x804cd1ec to cap IMPACT_DELTA
# assume sweet spot size == PUTT_IMPACT_CAP_FRAMES == 16

.4byte	0xc24cd1f8
.4byte	0x00000003

# at this point r9 == IMPACT_STRUCT_ADDR

# the original instruction
lwz		11, IMPACT_DELTA_FROM_IMPACT_STRUCT(9)

# now cap
cmpwi	11, PUTT_IMPACT_CAP_FRAMES_NEG
bge		done_cap_impact_delta
li		11, PUTT_IMPACT_CAP_FRAMES_NEG
stw		11, IMPACT_DELTA_FROM_IMPACT_STRUCT(9)

done_cap_impact_delta:

# gecko end injection
.4byte	0x00000000

# add delta_theta when perfect impact is missed
# note: (processed control stat) * (miss perfect impact %) is in f31, and (processed control stat) is from 0.02(max control) to 0.42(min control)

# the delta penalty is 1/4: 1-2 frame leeway for mid-range putt using Mario

.4byte	0xc24cd304
.4byte	0x00000005

lfs		8, THETA_FROM_SHOT_PARAMETERS(31)
lis		9, CONST_1_OVER_4_ADDR@ha
lfs		0, CONST_1_OVER_4_ADDR@l(9)

# note: impact late: f0 +ve; impact early: f0 -ve
bge		jump
fneg	0, 0

jump:
# f13 := f31 * f0 + f8
# jump to 0x804cd450 (exactly what we want)

lis		9, 0x804c
ori		9, 9, 0xd450
mtctr	9
bctr

.4byte	0x00000000

# if we're not putting, restore

.4byte	0x221d1c61
.4byte	0x0000000d

.4byte	0x0441406c
lbz		0, IMPACT_NUM_BUTTON_PRESSES_FROM_PLAYER_PARAMETERS(31)

.4byte	0x04414204
cmpwi	11, 1

.4byte	0x044142e8
stw		0, 0x7398(9)

.4byte	0x044cd1f8
lwz		11, IMPACT_DELTA_FROM_IMPACT_STRUCT(9)

.4byte	0x044cd304
lfs		7, 0x50(31)


.4byte	0xe0000000
.4byte	0x80008000
