from pygame_utils import *
import csv
import pygame

@dataclass
class Map:
    level = 0
    world= []
    wall_tiles = [129,131,159,160,161,189,190,191,219,220,221]
    tiles: pygame.Surface

    def load_map(filepath: str, tiles_image: str):
        Map.tiles = load_image(tiles_image)

        file = open(filepath, newline='\n')
        content = csv.reader(file)
        map = []
        for row in content:
            map.append(row)
        Map.world.append(map)

    def is_wall(x: int, y: int):
        map = Map.world[Map.level]
        for wall in Map.wall_tiles:
            if int(map[y][x]) == wall:
                return True
        return False

    def get_width():
        return len(Map.world[Map.level][0])

    def get_height():
        return len(Map.world[Map.level])

    def draw(screen: pygame.Surface, x: int, y: int):
        map = Map.world[Map.level]
        for i in range(len(map)):
            line = map[i]
            for j in range(len(line)):
                if (line[j] != '-1'):
                    clip = get_texture_clip_idx(Map.tiles, int(line[j]))
                    screen.blit(Map.tiles, (x+j*16, y+i*16), clip)

