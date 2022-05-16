
# ASCII Escape Codes: https://en.wikipedia.org/wiki/ANSI_escape_code
# Unicode table: https://en.wikipedia.org/wiki/List_of_Unicode_characters#Arrows

from random import randint
import time

# ESCAPE CODES
############################################

def hide_cursor():
  print("\033[?25l", end='')

def show_cursor():
  print("\033[?25h", end='')

def set_cursor(row, col):
  print("\033[%d;%dH" %(row, col), end='')

def set_color(color):
  print("\033[%dm" %(color), end='')

def clear_screen():
  print("\033[2J", end='')

# TESTES
############################################

def print_colors(base_color):
    for color in range(8):
        set_color(color+base_color)
        print('%02d' %(color), end=' ')
    print('\033[0m\n')

def print_box():
    for row in range(20):
        for col in range(20):
            set_cursor(row, col*2+1)
            set_color(randint(40,47))
            print('  ', end='')
    set_color(0)
    set_cursor(21,1)
    print()    

if __name__ == '__main__':
    clear_screen()

    for i in range(100):
        print_box()
        time.sleep(0.05)

    # cores basicas escuras
    print_colors(30)

    # cores basicas claras
    print_colors(90)
    
    # cores basicas (fundos)
    print_colors(40)

