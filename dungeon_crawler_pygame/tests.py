from dataclasses import dataclass
from pygame_utils import *

@dataclass
class Entity:
    instances: int = 0

    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y
        Entity.instances += 1
        self.instances += 1

    def print(self):
        print(self.x, self.y)

    def print_instances():
        print(Entity.instances)

@dataclass
class Player(Entity):
    
    def __init__(self, x: int, y: int, hp: int):
        self.hp = hp
        super().__init__(x, y)

# print(vars(Player))

player = Player(1,2,3)
print(player.x)
print(player.y)
print(player.hp)

player.print()
Entity.print_instances()