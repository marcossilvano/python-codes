from dataclasses import dataclass
import copy
import pygame

# CONSTANTS
#################################################################

COLOR_BLACK = (0, 0, 0)
COLOR_GREEN = (0, 255, 0)
COLOR_WHITE = (255, 255, 255)

# GENERAL UTILS
#################################################################

textures: list = {} # texture cache
font: pygame.font
keys = []
last_keys = []

def print_attributes(obj):
    for attr in vars(obj):
        if attr == '__match_args__':
            print(vars(obj)[attr])

def should_quit() -> bool:
    for event in pygame.event.get():
        if event.type == pygame.QUIT: 
            return True
        
    return False

# INPUT UTILS
#################################################################

def init_input():
    global keys
    keys = pygame.key.get_pressed()

def get_input():
    global keys, last_keys
    last_keys = copy.deepcopy(keys)
    keys = pygame.key.get_pressed()

def key_pressed(key_code) -> bool:
    global keys
    return keys[key_code]

def key_just_pressed(key_code) -> bool:
    global keys, last_keys
    return keys[key_code] and not last_keys[key_code]

def key_released(key_code) -> bool:
    global keys, last_keys
    return not keys[key_code] and last_keys[key_code]

# DRAWING UTILS
#################################################################

def draw_text(screen: pygame.Surface, font: pygame.font, text: str, x: int, y: int, color: pygame.Color) -> None:
    texture = font.render(text, False, color)
    rect= texture.get_rect()
    rect.topleft = (x, y)
    screen.blit(texture, rect)

def load_image(image_path: str, has_alpha: bool = True) -> pygame.Surface:
    global textures
    if image_path not in textures:
        if has_alpha:
            textures[image_path] = pygame.image.load(image_path).convert_alpha()    # textures cache (only load once)
        else:
            textures[image_path] = pygame.image.load(image_path).convert()

    return textures[image_path]

def get_texture_clip_idx(texture: pygame.Surface, index: int) -> pygame.Rect:
    index *= 16
    clip: pygame.Rect = (index % texture.get_width(), index // texture.get_width() * 16, 16, 16)
    return clip

def get_texture_clip_xy(texture: pygame.Surface, x: int, y: int) -> pygame.Rect:
    clip: pygame.Rect = (x * 16, y * 16, 16, 16)
    return clip

def blit_tile(screen: pygame.Surface, texture: pygame.Surface, index: int, x: int, y: int) -> None:
    clip = get_texture_clip_idx(texture, index)
    screen.blit(texture, (x, y), clip)

# MATH UTILS
#################################################################

def sign(value: float) -> int:
    if value < 0:
        return -1
    else:
        return 1

def move_towards(value: float, to: float, step: float) -> float:
    if abs(to - value) <= step:
        return to
    
    return value + step * sign(to - value)

# def test_move_towards() -> None:
#     x: int = 5
#     target: int = -5
#     while (x != target):
#         print(x)
#         x = move_towards(x, target, 0.5)
#     print(x)    
