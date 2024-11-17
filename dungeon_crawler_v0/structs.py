from dataclasses import dataclass

# CLASSES 
#########################################################

@dataclass
class InventoryItem:
    name: str
    stats: float

@dataclass
class Inventory:   
    weapon: InventoryItem
    armor: InventoryItem
    potions: int

@dataclass
class Entity:
    x: int = 1
    y: int = 1
    char: str = "😸"
    hp: float = 100
    damage: float = 0
    accuracy: float = 0
    defense: float = 0
    dexterity: float = 0
    critical: float = 0# chance de ocorrer um ataque crítico

@dataclass
class Player(Entity):
    xp: int = 0
    level: int = 0
    inventory: Inventory = 0