from hashlib import new
from math import ceil
from operator import truediv
from re import X
from typing import NamedTuple
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


class Cell(NamedTuple):
    dist: int
    pos: Point
    

def print_map(map):
    for line in map:
        for ch in line:
            if ch == 'X':
                print('██', end='')
            elif ch == ' ':
                print('  ', end='')
            elif ch == 'C':
                print('◨◧', end='')
            elif ch == 'S':
                print('SS', end='')
            elif ch == 'E':
                print('EE', end='')
        print()


# Returns the character at given position or 'N' if the position is out of map bounds
def get_cell(pos: Point, map: np.array):
    if pos.y > 0 and pos.y < map.shape[0]-1 and pos.x > 0 and pos.x < map.shape[1]-1:
        return map[pos.y][pos.x]
    else:
        return 'N'


def try_direction(pos: Point, dir: Point, map: np.ndarray) -> bool:
    new_pos: Point = pos + dir
    
    if get_cell(new_pos, map) == 'X':
        map[pos.y + dir.y//2][pos.x + dir.x//2] = ' ' # derruba parede
        return True

    return False


def print_and_wait() -> None:
    cs.clear_screen()
    print_map(map)
    input("Press to continue...")


def is_dead_end(p: Point, map: np.ndarray) -> bool:
    if map[p.y][p.x] != ' ':
        return False

    # check nearby cells:    up               down           left             right
    nearby_cells: list = [p + Point(-1,0), p + Point(1,0), p + Point(0,-1), p + Point(0,1)]

    walls_count: int = 0
    for nearby in nearby_cells:
        walls_count += int(map[nearby.y][nearby.x] == 'X')
    
    return walls_count >= 3


def gen_map(p: Point, map: np.ndarray, dist: int) -> Cell:
    map[p.y][p.x] = ' '
    #print_and_wait()

    # directions:         left          right        up        down
    dir_list: list = [Point(-2,0), Point(2,0), Point(0,-2), Point(0,2)]
    random.shuffle(dir_list)

    max_dist: Cell = Cell(dist, p)
    for dir in dir_list:
        if try_direction(p, dir, map):
            path_dist: Cell = gen_map(p + dir, map, dist+1)
            max_dist = path_dist if path_dist.dist > max_dist.dist else max_dist

    # detect a dead end and, if so, put a chest ('B')
    if is_dead_end(p, map):
        map[p.y][p.x] = 'C'

    return max_dist


if __name__ == '__main__':
    #cs.print_colors(30)

    dim: int = 31
    map = np.full((dim, dim), 'X')

    start_pos: Point = Point( random.randrange(1, dim, 2), random.randrange(1, dim, 2) )
    exit_cell: Cell = gen_map(start_pos, map, 0)

    '''
    for y in range(map.shape[0]):
        for x in range(map.shape[1]):
            if is_dead_end(Point(y,x), map):
                map[y][x] = 'B'
    '''

    #map[dim//2, dim//2] = 'S'
    map[start_pos.y, start_pos.x] = 'S'
    map[exit_cell.pos.y][exit_cell.pos.x] = 'E'

    print_and_wait()
    print('Max dist: %d at {%d, %d}' % (exit_cell.dist, exit_cell.pos.y, exit_cell.pos.x))
