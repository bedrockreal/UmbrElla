.if		(NO_STANDALONE != 1)
# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039
.endif

# pan sensitivity 0.125 -> 0.05
.long	0x044ec45c
.float	0.05

# horizontal pan range multiplier PI/180 -> 0.07
.long	0x044ec4b0
.float	0.07

# vertival pan range multiplier PI/6 -> 0.9
.long	0x044ec454
.float	0.9

# horizontal pan independent of camera sim line %
.long	0x04412588
fmr		0, 13

# end gecko code
.if		(NO_STANDALONE != 1)
.4byte	0xe0000000
.4byte	0x80008000
.endif
