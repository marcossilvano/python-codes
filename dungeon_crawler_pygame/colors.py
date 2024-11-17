
# ASCII Escape Codes: https://en.wikipedia.org/wiki/ANSI_escape_code
# Unicode table: https://en.wikipedia.org/wiki/List_of_Unicode_characters#Arrows
# Unicode emoji: https://unicode.org/emoji/charts/full-emoji-list.html

from random import randint
import time

DEFAULT_FG_COLOR = 39
DEFAULT_BG_COLOR = 49

# ESCAPE CODES
############################################

def hide_cursor():
  print("\033[?25l", end='')

def show_cursor():
  print("\033[?25h", end='')

def set_cursor(x: int, y: int):
  print("\033[%d;%dH" % (y, x), end='')

def set_color(color: int):
  print("\033[%dm" % (color), end='')

def clear_screen():
  print("\033[2J", end='')

def reset_color():
  print("\033[0m", end="")


# TESTES
############################################

def print_colors(start_color, end_color):
    for color in range(start_color, end_color+1):
        set_color(color)
        print('%02d' %(color), end=' ')
    print('\033[0m\n')

def print_box():
    for row in range(10):
        for col in range(10):
            set_cursor(col*2+1, row)
            # set_color(randint(40,47))
            set_color(randint(30,37))
            # set_color(randint(0,1) * 60 + randint(40,47))
            print(chr(ord("😸") + randint(0,8)), end='')
    set_color(0)
    set_cursor(21,1)
    print()    

if __name__ == '__main__':
    clear_screen()

    for i in range(100):
        print_box()
        time.sleep(0.05)

    set_cursor(1, 11)
    print_colors(30, 37) # cores basicas escuras
    print_colors(90, 97) # cores basicas claras
    
    print_colors(40, 47) # cores basicas (fundos)
    print_colors(100, 107)
