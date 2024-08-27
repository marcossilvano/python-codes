from colors import *
from sprites import *
from random import randint

def draw_ascii():
  img = '''
    ████████    
    ██░░░░██    
  ▓▓▓▓▒▒▒▒▓▓▓▓  
▒▒  ██▓▓▓▓██  ▒▒
▒▒  ▓▓████▓▓  ▒▒
██  ██▓▓▓▓██  ██
    ░░    ░░    
    ▒▒    ▒▒    
'''
  print(img)


def draw_colors(start, end):
  for c in range(start, end+1):
    set_color(c)
    # print(' %03d ' % c, end='')
    print('  ', end='')
    # reset_color()
    # print(' ', end='')
  reset_color()
  print()


def print_palette():
  draw_colors(40,47)
  draw_colors(100,107)
  print()


def draw_16colors(sprite, posx, posy):
  data = sprite['data']
  y = 0
  while y < sprite['height']:
    x = 0
    while x < sprite["width"]:
      set_cursor(posx + x, posy + y)
      if data[y][x] == 0:
        reset_color()
        print(' ', end='')
      else:
        set_palette_color(data[y][x], 30, 90)
        print('█', end='')
      x += 1
    reset_color()
    print()
    y += 1
  print()


def set_high_pixel(px: int):
  if (px == 0):
    set_palette_color(1, 40, 100) # background color
  else:
    set_palette_color(px, 40, 100)


def set_low_pixel(px: int):
  if (px == 0):
    set_palette_color(1, 30, 90)  # foreground color
  else:
    set_palette_color(px, 30, 90)


def set_palette_color(px: int, low: int, high: int):
  if px > 8:
    set_color(px-9 + high)
  else:
    set_color(px-1 + low)


def draw_half_16colors(sprite, posx, posy):
  data = sprite['data']
  y = 0
  while y < sprite['height']:
    x = 0
    while x < sprite["width"]:
      set_high_pixel(data[y][x])  # high pixel      
      if y+1 < sprite["height"]:
        set_low_pixel(data[y+1][x]) # low pixel
      else:
        set_low_pixel(1)

      set_cursor(posx + x//2, posy + y//2)
      print('▄', end='')
      x += 2
    reset_color()
    print()
    y += 2
  print()

def draw_box(x, y, w, h):
  for i in range(0,h):
    for j in range(0,w):
      set_cursor(x+j, y+i)
      set_color(30) # char black
      print('█', end='')


if __name__ == '__main__':
  hide_cursor()
  clear_screen()
  # print_palette()
  # draw_ascii()

  # for key in sprites:
  #   draw_16colors(sprites[key], 5, 5)

  # for key in sprites:
  #   draw_half_16colors(sprites[key], 40, 12)

  draw_16colors(sprites["Mario0"], 5, 5)
  draw_half_16colors(sprites["Mario0"], 40, 13)
  # x = 5
  # y = 5
  # for i in range(0,20):
  #   draw_16colors(sprites["Mario" + str(i%2)], x, y)
  #   time.sleep(0.1)

  show_cursor()
  set_cursor(1, 21)