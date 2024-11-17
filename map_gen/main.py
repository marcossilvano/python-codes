from hashlib import new
from math import ceil
from operator import truediv
from re import X
from typing import NamedTuple
import numpy as np
import colors as cs
import random

class Cell:
    def __init__(self, row: int, col: int, dist: int = 0):
        self.row = row
        self.col = col
        self.dist = dist

    def __str__(self) -> str:
        return '{row:' + str(self.row) + ', col:' + str(self.col) + ', dist: ' + str(self.dist) + '}'

    def __repr__(self) -> str:
        return self.__str__(self)

    def __add__(self, other) -> object:
        p = Cell(self.row, self.col)
        p.row += other.row
        p.col += other.col
        return p

    def __getitem__(self, index) -> int:
        if index == 0:
            return self.row
        if index == 1:
            return self.col
        if index == 2:
            return self.dist
    

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


def print_map_codes(map):
    for line in map:
        for ch in line:
            print(ch, end='')
        print()


# Returns the character at given position or 'N' if the position is out of map bounds
def get_cell(pos: Cell, map: np.array):
    if pos.row > 0 and pos.row < map.shape[0]-1 and pos.col > 0 and pos.col < map.shape[1]-1:
        return map[pos.row, pos.col]
    else:
        return 'N'


def try_direction(pos: Cell, dir: Cell, map: np.ndarray) -> bool:
    new_pos: Cell = pos + dir
    
    if get_cell(new_pos, map) == 'X':
        map[pos.row + dir.row//2, pos.col + dir.col//2] = ' ' # derruba parede
        return True

    return False


def print_and_wait() -> None:
    cs.clear_screen()
    print_map(map)
    #print_map_codes(map)
    input("Press to continue...")


def is_dead_end(p: Cell, map: np.ndarray) -> bool:
    if map[p.row, p.col] != ' ':
        return False

    # check nearby cells:       up             down           left             right
    nearby_cells: list = [p + Cell(-1,0), p + Cell(1,0), p + Cell(0,-1), p + Cell(0,1)]

    walls_count: int = 0
    for nearby in nearby_cells:
        walls_count += int(map[nearby.row, nearby.col] == 'X')
    
    return walls_count >= 3


def gen_map(p: Cell, map: np.ndarray, dist: int) -> Cell:
    map[p.row, p.col] = ' '
    #print_and_wait()

    # directions:         left          right        up        down
    dir_list: list = [Cell(-2,0), Cell(2,0), Cell(0,-2), Cell(0,2)]
    random.shuffle(dir_list)

    max_dist: Cell = Cell(p.row, p.col, dist)
    for dir in dir_list:
        if try_direction(p, dir, map):
            path_dist: Cell = gen_map(p + dir, map, dist+1)
            max_dist = path_dist if path_dist.dist > max_dist.dist else max_dist

    # detect a dead end and, if so, put a chest ('B')
    if is_dead_end(p, map):
        #if random.randint(1,3) >= 3:
        map[p.row, p.col] = 'C'

    return max_dist


if __name__ == '__main__':
    #cs.print_colors(30)

    map_rows: int = 25
    map_cols: int = 41
    map = np.full((map_rows, map_cols), 'X')

    pos_start: Cell = Cell( random.randrange(1, map_rows, 2), random.randrange(1, map_cols, 2) )
    pos_exit: Cell = gen_map(pos_start, map, 0)

    map[pos_start.row, pos_start.col] = 'S'
    map[pos_exit.row, pos_exit.col] = 'E'

    print_and_wait()
    #print('Max dist: %d at {%d, %d}' % (pos_exit.dist, pos_exit.col, pos_exit.row))