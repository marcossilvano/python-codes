# DATA AND VARIABLES
#########################################################

level = 0

world= [
[ # LEVEL 0
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"X X     X                  X      X",
"X X XXXXXXXXXXXXXXXXXXXXXX X      X",
"X X                        X      X",
"X XXXXXXXXXXX XXXXXXXXXXXXXX      X",
"X           X                     X",
"X XXXXXXXXX X XXXXXXXXXXXXXXXXXXXXX",
"X X  X    X X    XXXXXXXXXXXXXXXXXX",
"X X  X XXXX XXXX                  X",
"X X  X X    XXXX                  X",
"X X  X X  XXXXXX                  X",
"X X  X         X                  X",
"X    X XXXXXXXXX                  X",
"X X  X         X                  X",
"X X  XXXXXXXXXXX                  X",
"X              X                  X",
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
]
]

def map_is_wall(x: int, y: int):
    global level
    map = world[level]
    return map[y][x] == 'X'

def map_width(level: int):
    return len(world[level][0]*2)

def map_height(level: int):
    return len(world[level])
