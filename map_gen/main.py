from hashlib import new
from operator import truediv
from re import X
import numpy as np
import colors as cs
import random

class Point:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    def __str__(self) -> str:
        return '(x:' + str(self.x) + ', y:' + str(self.y) + ')'

    def __repr__(self) -> str:
        return self.__str__(self)

    def __add__(self, other) -> object:
        p = Point(self.x, self.y)
        p.x += other.x
        p.y += other.y
        return p

    def __getitem__(self, index) -> int:
        if index == 0:
            return self.y
        if index == 1:
            return self.x


def print_map(map):
    for line in map:
        for ch in line:
            if ch == 'X':
                print('██', end='')
            elif ch == ' ':
                print('  ', end='')
            elif ch == 'B':
                print('▒▒', end='')

        print()


def try_direction(pos: Point, dir: Point, map: np.ndarray) -> bool:
    new_pos = pos + dir
    
    if new_pos.y > 0 and new_pos.y < map.shape[0]-1 and new_pos.x > 0 and new_pos.x < map.shape[1]-1:
        if map[new_pos.y][new_pos.x] == 'X':
            map[pos.y + dir.y//2][pos.x + dir.x//2] = ' ' # derruba parede
            return True
    
    return False


def print_and_wait():
    cs.clear_screen()
    print_map(map)
    input("Press to continue...")


def gen_map(p: Point, map: np.ndarray):
    map[p.y][p.x] = ' '
    print_and_wait()

    # directions:         left          right        up        down
    dir_list: list = [Point(-2,0), Point(2,0), Point(0,-2), Point(0,2)]
    random.shuffle(dir_list)

    for dir in dir_list:
        if try_direction(p, dir, map):
            gen_map(p + dir, map)

    #map[p.y][p.x] = 'B'

def gen_map_old(y: int, x: int, map: np.ndarray):

    map[y][x] = ' '
    cs.clear_screen()
    print_map(map)
    input("Press to continue...")

    if y-2 > 0:
        if map[y-2][x] == 'X':  # up
            map[y-1][x] = ' '
            gen_map(y-2, x, map)

    if x+2 < map.shape[1]-1:
        if map[y][x+2] == 'X':  # right
            map[y][x+1] = ' '
            gen_map(y, x+2, map)

    if x-2 > 0:
        if map[y][x-2] == 'X':  # left
            map[y][x-1] = ' '
            gen_map(y, x-2, map)

    if y+2 < map.shape[0]-1:
        if map[y+2][x] == 'X':  # down
            map[y+1][x] = ' '
            gen_map(y+2, x, map)


if __name__ == '__main__':
    #cs.print_colors(30)

    map = np.full((19, 19), 'X')

    gen_map(Point(9,9), map)
#    print_and_wait()