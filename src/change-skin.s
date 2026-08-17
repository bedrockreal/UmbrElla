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
.4byte	0x00000006

# r30 is the botton press (not hold) mask. check if (r30 & 0x800) != 0, iff Y is pressed

# as of note on line 27, lis is moved here
lis		9, 0x804f
andi.	0, 30, 0x800
beq		YButtonNotPressed

#	execution reaches here at the 1st frame Y button is indeed pressed.

# set r0 = *(0x804f3850), the CSS cursor's column index (0-indexed), which corresponds to the GBA character index
# note: we move the lis before the branch, so that the r9 is always 0x804f regardless of branch, and the replaced instruction need not be restored.

lwz		0, 0x3850(9)

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


YButtonNotPressed:

#	no need to restore replaced instruction 'lis r9, 0x804f'

# end gecko code
nop
.4byte	0x00000000
.4byte	0xe0000000
.4byte	0x80008000
