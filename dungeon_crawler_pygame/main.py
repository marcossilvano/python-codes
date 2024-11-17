# Unicode table: https://en.wikipedia.org/wiki/List_of_Unicode_characters#Arrows
# Unicode emoji: https://unicode.org/emoji/charts/full-emoji-list.html
# PyGame: https://www.pygame.org/docs/

from colors import *
from structs import *
from world import *
from dialog import *
from pygame_utils import *

import pygame, random

from dataclasses import dataclass

# CONSTANTS
#########################################################

WIDTH = 800
HEIGHT= WIDTH*(9/16)

# GLOBALS
#########################################################

player: Player
run = True
level_tiles: pygame.Surface

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

def draw_entity(ent: Entity):
    # set_cursor(ent.y, ent.x)
    print(ent.char, end="")


def show_message(key: str):
    global msg_key
    msg_key = key


def draw_message():
    set_cursor(1, Map.get_height() + 4)
    print(messages[msg_key], end="")


def draw_stats():
    set_cursor(Map.get_width() + 7, 2)
    print("S-T-A-T-S", end="")


def draw_game(screen: pygame.Surface):
    screen.fill(COLOR_BLACK)
    Map.draw(screen, 0, 0)    
    player.draw(screen)
    # draw_stats()
    # draw_message()

def update_game():
    player.update()

def init_game():
    init_input()

    Map.load_map('assets/level1.csv', 'assets/tiles-2.png')

    global player
    player = Player('assets/player_16x16.png', 1, 1)

def main():
    pygame.init()
    # screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.FULLSCREEN | pygame.SCALED)
    screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.SCALED)
    pygame.display.set_caption("Dungeon Claw")
        
    clock = pygame.time.Clock()
    dt = 0

    global font
    font = pygame.font.Font('fonts/dragon-warrior-nes.ttf', 8)

    dialog = TextDialog(200, 100)
    dialog2 = MenuDialog()
    dialog3 = TextDialog(200, 100)
    init_game()

    while not should_quit():
        get_input()
        if key_just_pressed(pygame.K_ESCAPE): break

        if key_just_pressed(pygame.K_SPACE): 
            dialog.show("Texto de teste\nTexto de teste\nTexto de teste\nTexto de teste", 10, 10)
            dialog3.show("Texto de teste\nTexto de teste\nTexto de teste\nTexto de teste", 200, 200)
        
        if key_just_pressed(pygame.K_RETURN): 
            dialog2.show(250, 10)

        update_game()

        dialog.update()
        dialog2.update()
        dialog3.update()

        draw_game(screen)
        draw_text(screen, font, 'FPS: %02d' % (clock.get_fps()), (WIDTH - 70), 10, COLOR_GREEN)

        dialog.draw(screen)
        dialog2.draw(screen)
        dialog3.draw(screen)

        pygame.display.flip()
        dt = clock.tick(60)/1000 # sync to 60 fps

    pygame.quit()

if __name__ == '__main__':
    main()
    # test_move_towards()