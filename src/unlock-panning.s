# check for the right file
.4byte	0x20416dbc
.4byte	0x3f608039

# horizontal pan sensitivity 0.125 -> 0.05
.long	0x044ec45c
.float	0.05

# horizontal pan range multiplier PI/18 -> 0.07
.long	0x044ec4b0
.float	0.07

# vertival pan range multiplier 0.7 -> 1
.long	0x044ec4b8
.float	1

# end gecko code
.4byte	0xe0000000
.4byte	0x80008000
