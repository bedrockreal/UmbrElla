#	Assembly code to change Neil/Ella's skin by pressing Y on the GBA CSS
#	inject before 0x8040e378, only executed if player is at the GBA CSS and not changing character
#	free registers: r0, r9, r10, r11

# check for the right file
.4byte	0x2040e374
.4byte	0x409e000c

# forces the game to load GBA data from 1st slot
.4byte	0x044165ac
li		28, 0

# main code: inject into 0x8040e378
.4byte	0xc240e378
.4byte	0x00000008

# r30 is the botton press (not hold) mask. check if (r30 & 0x800) != 0, iff Y is pressed

andi.	0, 30, 0x800
beq		YButtonNotPressed

#	execution reaches here at the 1st frame Y button is pressed.

# set r0 = *(0x804f3850), the CSS cursor's column index (0-indexed), which corresponds to the GBA character index

.set	CSS_CURSOR_COL_IDX_ADDR,	0x804f3850
lis		9, CSS_CURSOR_COL_IDX_ADDR@ha
lwz		0, CSS_CURSOR_COL_IDX_ADDR@l(9)

#	now load the tile -> ID array address (0x804ed86c) onto r9
.set	TILE_TO_ID_ARR_ADDR,	0x804ed86c

#	now we want to modify the word at TILE_TO_ID_ARR_ADDR + ((r0 & 0x1) << 2) (here we and it with 0x1 since we've forced loading from GBA slot 0

#	r11 = (r0 & 1) << 2
rlwinm	11, 0, 2, 29, 29

# load the word onto r10, then update r11 to the address
addi	11, 11, TILE_TO_ID_ARR_ADDR@l
lwzux	10, 11, 9

# set r10 := (r10 + 2) % 8
addic	10, 10, 2
andi.	10, 10, 7

# store r10
stw		10, 0x0(11)

.set	CSS_TILE_INTERLACE_ADDR,	0x804f3874
.set	CSS_ANIM_BASE_ADDR,			0x804f11e4
.set	CHAR_ID_FROM_CSS_ANIM,		0x94
.set	TARGET,	CSS_ANIM_BASE_ADDR+CHAR_ID_FROM_CSS_ANIM

# lwz		11, CSS_TILE_INTERLACE_ADDR@l(9)
# neg		11, 11
# stw		11, CSS_TILE_INTERLACE_ADDR@l(9)

# call CSSChangeCharAnim @ 0x8040ba08
.set	CSS_CHANGE_ANIM_ADDR,	0x8040ba08
lis		9, CSS_CHANGE_ANIM_ADDR@h
ori		9, 9, CSS_CHANGE_ANIM_ADDR@l
mtctr	9
bctrl

# mulli	11, 11, 0xa8
# 
# # store real character ID (= r10 + 16) into CSS_ANIM_BASE_ADDR + r11 + CHAR_ID_FROM_CSS_ANIM = TARGET + r11 = r9 + r11 + TARGET@l
# addi	10, 10, 0x10
# addi	11, 11, TARGET@l
# stwx	10, 11, 9

YButtonNotPressed:
# restore replaced instruction: this is needed because r9 is overwritten by CSSChangeCharAnim
lis		9, 0x804f

# end gecko code
.4byte	0x00000000
.4byte	0xe0000000
.4byte	0x80008000
