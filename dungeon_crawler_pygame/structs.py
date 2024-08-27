from dataclasses import dataclass
from typing import List
from pygame_utils import *
from world import *
import pygame

# CLASSES 
#########################################################

@dataclass
class InventoryItem:
    def __init__(self, name: str, stats: float):
        self.name = name
        self.stats = stats

@dataclass
class Inventory:   

    def __init__(self):
        self.weapon = InventoryItem("Wooden Sword", 5)
        self.armor  = InventoryItem("Wooden Armor", 5)
        self.potions= 0

@dataclass
class Animation:

    def __init__(self, frames: List[int], frame_time: int = 10, loop: bool = True) -> None:
        self.frames = frames
        self.current_frame = 0
        self.frame_counter = 0
        self.frame_time = frame_time
        self.loop = loop

    def animate(self):
        self.frame_counter += 1
        if self.frame_counter > self.frame_time:
            self.frame_counter = 0
            self.current_frame += 1
            if self.current_frame >= len(self.frames):
                if self.loop:
                    self.current_frame = 0
                else:
                    self.current_frame = len(self.frames)-1
    

@dataclass
class Entity:
    
    def __init__(self, texture_file: str, x: int , y: int):
        self.x = x
        self.y = y
        self.animations = {}
        self.texture = load_image(texture_file)
        self.hp = 0
        self.current_animation = 'idle'

    def draw(self, screen: pygame.Surface):
        self.animations[self.current_animation].animate()
        anim: Animation = self.animations[self.current_animation]
        clip = get_texture_clip_idx(self.texture, anim.frames[anim.current_frame])
        screen.blit(self.texture, (self.x*16, self.y*16), clip)

    def set_animation(self, anim_name: str):
        if anim_name == self.current_animation:
            return
        self.current_animation = anim_name
        anim: Animation = self.animations[self.current_animation]
        anim.current_frame = 0
        anim.frame_counter = 0

@dataclass
class Player(Entity):

    def __init__(self, texture_file: str, x: int , y: int):
        super().__init__(texture_file, x, y)
        self.xp = 0
        self.level = 0
        self.inventory = Inventory()
        self.next_x = x
        self.next_y = y
        self.vel_x = 0
        self.vel_y = 0
        self.last_vel_x = 0
        self.last_vel_y = 0

        self.animations["idle"]      = Animation([0])
        self.animations["run_left"]  = Animation([2,3])
        self.animations["run_right"] = Animation([6,7])
        self.animations["run_up"]    = Animation([4,5])
        self.animations["run_down"]  = Animation([0,1])
        self.set_animation("run_down")    

    
    def try_turn_at_corner(self):
        if self.vel_x != 0: # try to go up or down
            if self.last_vel_y == 0:
                self.last_vel_y = 1

            if not Map.is_wall(self.x + self.vel_x, self.y + self.last_vel_y):
                self.next_y = self.y + self.last_vel_y
            elif not Map.is_wall(self.x + self.vel_x, self.y - self.last_vel_y):                
                self.next_y = self.y - self.last_vel_y

        elif self.vel_y != 0: # try to go left or down
            if self.last_vel_x == 0:
                self.last_vel_x = 1

            if not Map.is_wall(self.x + self.last_vel_x, self.y + self.vel_y):
                self.next_x = self.x + self.last_vel_x
            if not Map.is_wall(self.x - self.last_vel_x, self.y + self.vel_y):
                self.next_x = self.x - self.last_vel_x

    def update(self):
        self.x = move_towards(self.x, self.next_x, 0.1)
        self.y = move_towards(self.y, self.next_y, 0.1)
        if self.x != self.next_x or self.y != self.next_y:
            self.last_vel_x = self.vel_x
            self.last_vel_y = self.vel_y
            return
        
        self.vel_x = 0
        self.vel_y = 0

        if key_pressed(pygame.K_LEFT):
            self.vel_x = -1
            self.set_animation("run_left")
        elif key_pressed(pygame.K_RIGHT):
            self.vel_x = 1
            self.set_animation("run_right")
        elif key_pressed(pygame.K_UP):
            self.vel_y = -1
            self.set_animation("run_up")
        elif key_pressed(pygame.K_DOWN):
            self.vel_y = 1
            self.set_animation("run_down")
        # else:
            # self.set_animation("idle")

        # case "q": run = False
        # case _: show_message("?")
        
        # check for walls
        if Map.is_wall(self.x + self.vel_x, self.y + self.vel_y):       
            self.try_turn_at_corner()
        else:
            self.next_x = self.x + self.vel_x
            self.next_y = self.y + self.vel_y