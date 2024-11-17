# Unicode table: https://en.wikipedia.org/wiki/List_of_Unicode_characters#Arrows
# Unicode emoji: https://unicode.org/emoji/charts/full-emoji-list.html

from colors import *
from structs import *
from world import *

from dataclasses import dataclass
import time

player = Player()
run = True

messages = {
    "begin": "The level has started",
    "?": "Unknown command",
    "x": "Player has hit a wall",
    "w": "Player has moved up",
    "s": "Player has moved down",
    "a": "Player has moved left",
    "d": "Player has moved right",
    "q": "Player has exited the game"
}
msg_key = "begin"

# CODE 
#########################################################

def draw_map(map):
    set_cursor(1,1)
    bricks = ["🔳","🔲"]
    # bricks = ["█","▓","▒","░"]
    # colors = [37,90,97]

    clear_screen()
    for i in range(len(map)):
        line = map[i]
        for j in range(len(line)):
            # set_cursor(i, j*2)
            match line[j]:
                case 'X':
                    set_color(41)
                    print(bricks[randint(0,len(bricks)-1)] , end="")

                    # wall = bricks[randint(0,1)]
                    # print("%s%s" % (wall,wall) , end="")
                    
                    # set_color(colors[randint(0,1)])
                    # print("██", end='')
                case _:
                    reset_color()
                    if j == player.x and i == player.y:
                        draw_entity(player)
                    else:
                        print("  ", end="")

        reset_color()
        print()


def draw_entity(ent: Entity):
    # set_cursor(ent.y, ent.x)
    print(ent.char, end="")


def show_message(key: str):
    global msg_key
    msg_key = key


def draw_message():
    set_cursor(1, map_height(level) + 4)
    print(messages[msg_key], end="")


def draw_stats():
    set_cursor(map_width(level) + 7, 2)
    print("S-T-A-T-S", end="")


def draw_game():
    draw_map(world[level])    
    draw_stats()
    draw_message()


def get_input():
    global run, msg_key
    set_cursor(1, map_height(level) + 2)
    command: str = input("What is your command?\n > ")
    
    # for c in command:
    vel_x = 0
    vel_y = 0
    show_message(command[0])
    match command[0]:
        case "w": vel_y = -1
        case "s": vel_y =  1
        case "a": vel_x = -1
        case "d": vel_x =  1
        case "q": run = False
        case _: show_message("?")
    
    # check for walls
    if not map_is_wall(player.x + vel_x, player.y + vel_y):
        player.x += vel_x
        player.y += vel_y
    else:
        show_message("x")


def init_game():
    player.x = 1
    player.y = 1


def main():
    init_game()

    while run:
        draw_game()
        get_input()

    # going to terminal
    draw_message()
    set_cursor(1, map_height(level) + 6)

def sign(value: float) -> int:
    if value < 0:
        return -1
    else:
        return 1

def move_towards(value: float, to: float, step: float) -> float:
    if abs(to - value) <= step:
        return to
    
    return value + step * sign(to - value)

def test_move_towards() -> None:
    x: int = 5
    target: int = -5
    while (x != target):
        print(x)
        x = move_towards(x, target, 0.5)
    print(x)    

if __name__ == '__main__':
    # main()    
    test_move_towards()