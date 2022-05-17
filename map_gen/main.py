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


# Returns the character at given position or 'N' if the position is out of map bounds
def get_cell(pos: Point, map: np.array):
    if pos.y > 0 and pos.y < map.shape[0]-1 and pos.x > 0 and pos.x < map.shape[1]-1:
        return map[pos.y][pos.x]
    else:
        return 'N'


def try_direction(pos: Point, dir: Point, map: np.ndarray) -> bool:
    new_pos = pos + dir
    
    if get_cell(new_pos, map) == 'X':
        map[pos.y + dir.y//2][pos.x + dir.x//2] = ' ' # derruba parede
        return True

#    if new_pos.y > 0 and new_pos.y < map.shape[0]-1 and new_pos.x > 0 and new_pos.x < map.shape[1]-1:
#        if map[new_pos.y][new_pos.x] == 'X':
#            map[pos.y + dir.y//2][pos.x + dir.x//2] = ' ' # derruba parede
#            return True
    
    return False


def print_and_wait():
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


def gen_map(p: Point, map: np.ndarray):
    map[p.y][p.x] = ' '
    #print_and_wait()

    # directions:         left          right        up        down
    dir_list: list = [Point(-2,0), Point(2,0), Point(0,-2), Point(0,2)]
    random.shuffle(dir_list)

    for dir in dir_list:
        if try_direction(p, dir, map):
            gen_map(p + dir, map)

    # detect a dead end and, if so, put a chest ('B')
    if is_dead_end(p, map):
        map[p.y][p.x] = 'B'


if __name__ == '__main__':
    #cs.print_colors(30)

    dim: int = 31
    map = np.full((dim, dim), 'X')

    gen_map(Point(dim//2, dim//2), map)

    '''
    for y in range(map.shape[0]):
        for x in range(map.shape[1]):
            if is_dead_end(Point(y,x), map):
                map[y][x] = 'B'
    '''

    print_and_wait()
