#	Assembly code to change Neil/Ella's skin by pressing Y on the GBA CSS
#	inject before 0x804fe378, only executed if player is at the GBA CSS and not changing character
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

#	check if (r26 & 0x800) != 0, if and only if the Y button is pressed.
#	We want to activate skin change when the Y button is first pressed (don't change when holding). The previous value of r26 is stored in 0x801d1c24 (contains unused, BBA-related debug string), with value 64 62 61 6e (not interfering with 0x800)

# as of note on line 33, lis is moved here
lis		9, 0x804f

lis		11, 0x801d
lwz		10, 0x1c24(11)
stw		26, 0x1c24(11)
andc	10, 26, 10
andi.	10, 10, 0x800
beq		YButtonNotPressed

#	execution reaches here iff the Y button is indeed pressed.

# set r0 = *(0x804f3850), the CSS cursor's column index (0-indexed), which corresponds to the GBA character index
# note: we move the lis before the branch, so that the r9 is always 0x804f regardless of branch, and the replaced instruction need not be restored.

lwz		0, 0x3850(9)

#	since we forced loading GBA pair 0, mod r0 by 2
andi.	0, 0, 1

#	now load the tile -> ID array address (0x804ed86c) onto r9
#	note:: we don't load this address directly onto r9, but notice that 0x804ed86c = 0x804f0000 - 0x2794, so we load 0x804f0000 onto r9 (already done), then add an offset of -0x2794 for every load and store

# lis		9, 0x804f
# lis		9, 0x804e
# addi	9, 9, 0xd86c

#	the title -> ID array is an int array (each element is 4 bytes long). set r11 = r9 + r0 * 4 so that r11 points to the exact element to be modified
slwi	0, 0, 2
add		11, 9, 0

#	now, load the word pointed by r9 (call it x), set x := (x + 2) % 8, and store it back
#	remark: as of line 28, we add the offset every time here.

lwz		10, -0x2794(11)
addi	10, 10, 2
andi.	10, 10, 7
stw		10, -0x2794(11)


YButtonNotPressed:

#	no need to restore replaced instruction 'lis	r9, 0x804f'

# end gecko code
.4byte	0x00000000
.4byte	0xe0000000
.4byte	0x80008000
