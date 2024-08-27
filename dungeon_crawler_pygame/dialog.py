from dataclasses import dataclass
from typing import List
from pygame_utils import *
import pygame

# DIALOG
########################################################################

@dataclass
class Dialog:
    LINE_HORIZONTAL = 0
    LINE_VERTICAL   = 1

    STATE_OPEN = 0
    STATE_RUN  = 1
    STATE_CLOSE= 2
    STATE_WAIT = 3
    
    def __init__(self, width: int, height: int):
        self.texture = load_image('assets/dialog.png')
        self.x = 0
        self.y = 0
        self.width = width
        self.height = height

        self.bgcolor = (0,0,0)
        self.visible = False
        
        self.state = Dialog.STATE_WAIT
        self.count_h = 16

    def _draw_line(self, screen: pygame.Surface, x: int, y: int, length: int, tile: int, type: int):
            if type == Dialog.LINE_HORIZONTAL:
                for i in range(0, length//16):
                    blit_tile(screen, self.texture, tile, x+i*16, y)        
            else:
                for i in range(0, length//16):
                    blit_tile(screen, self.texture, tile, x, y+i*16)        


    def draw_box(self, screen: pygame.Surface, width: int, height: int) -> None:
        width16 = width//16*16
        height16= height//16*16

        offset_x: int = (width - width16)//2
        offset_y: int = (height - height16)//2

        # lines
        self._draw_line(screen, self.x + offset_x, self.y, width16, 1, Dialog.LINE_HORIZONTAL)
        self._draw_line(screen, self.x + offset_x, self.y + height-16, width16, 7, Dialog.LINE_HORIZONTAL)
        self._draw_line(screen, self.x, self.y + offset_y, height16, 3, Dialog.LINE_VERTICAL)
        self._draw_line(screen, self.x + width-16, self.y + offset_y, height16, 5, Dialog.LINE_VERTICAL)

        # corners
        blit_tile(screen, self.texture, 0, self.x, self.y)
        blit_tile(screen, self.texture, 2, self.x + width-16, self.y)
        blit_tile(screen, self.texture, 6, self.x, self.y + height-16)
        blit_tile(screen, self.texture, 8, self.x + width-16, self.y + height-16)    


    def show(self, x: int, y: int) -> bool:
        if self.state != Dialog.STATE_WAIT:
            return False
        
        self.x = x
        self.y = y
        self.visible = True
        self.count_h = 16
        self.state = Dialog.STATE_OPEN
        return True


    def update(self) -> None:
        match self.state:
            case Dialog.STATE_OPEN:
                self.count_h = move_towards(self.count_h, self.height, 5)
                if self.count_h == self.height:
                    self.state = Dialog.STATE_RUN

            case Dialog.STATE_CLOSE:
                self.count_h = move_towards(self.count_h, 16, 5)
                if self.count_h == 16:
                    self.state = Dialog.STATE_WAIT
                    self.visible = False
                
            case Dialog.STATE_RUN:
                self.run_state()


    def draw(self, screen: pygame.Surface) -> None:
        if not self.visible:
            return
        
        pygame.draw.rect(screen, self.bgcolor, (self.x+2, self.y+2, self.width-4, self.count_h-4))
        self.draw_box(screen, self.width, self.count_h)

        match self.state:
            case Dialog.STATE_RUN:
                self.draw_run_state(screen)

    # abstract
    def update_run_state(self) -> None:
        pass

    # abstract
    def draw_run_state(self, screen: pygame.Surface) -> None:
        pass

# TEXT DIALOG
########################################################################

@dataclass
class TextDialog(Dialog):
    
    def __init__(self, width: int, height: int):
        super().__init__(width, height)
        self.font = pygame.font.Font('fonts/dragon-warrior-nes.ttf', 8)
        self.char_count = 0
        self.delay = 1
        self.done = False
        self.text = ""


    # override
    def show(self, text: str, x: int, y: int):
        if not super().show(x, y):
            return
        self.text = text
        self.char_count = 0
        self.done = False


    # override
    def run_state(self) -> None:
        if self.done:
            if key_just_pressed(pygame.K_SPACE):
                self.state = Dialog.STATE_CLOSE
            return

        self.delay -= 1
        if self.delay == 0:
            self.delay = 1

            self.char_count += 1
            if self.char_count > len(self.text):
                self.char_count = len(self.text)
                self.done = True


    def _draw_text(self, screen: pygame.Surface) -> None:
        lines: List[str] = self.text[0:self.char_count].split('\n')
        line_space = self.font.get_height() + 5

        for i in range(0, len(lines)):
            draw_text(screen, self.font, lines[i], self.x+10, self.y+10 + i*line_space, COLOR_WHITE)
            i += 1


    # override
    def draw_run_state(self, screen: pygame.Surface) -> None:
        self._draw_text(screen)

# MENU DIALOG
########################################################################

@dataclass
class MenuDialog(Dialog):
    
    def __init__(self):
        super().__init__(120, 70)
        self.font = pygame.font.Font('fonts/dragon-warrior-nes.ttf', 8)
        self.options = ['Attack', 'Defend', 'Potion', 'Run']
        self.current_option = 0
        self.pointer = load_image('assets/pointer.png')


    # override
    def show(self, x: int, y: int):
        if not super().show(x, y):
            return
        self.current_option = 0


    # override
    def run_state(self) -> None:
        if key_just_pressed(pygame.K_RETURN):
            self.state = Dialog.STATE_CLOSE
            return
        
        if key_just_pressed(pygame.K_DOWN):
            self.current_option += 1
            if self.current_option >= len(self.options):
                self.current_option = 0

        elif key_just_pressed(pygame.K_UP):
            self.current_option -= 1
            if self.current_option < 0:
                self.current_option = len(self.options) - 1


    def _draw_options(self, screen: pygame.Surface) -> None:
        line_space = self.font.get_height() + 5

        for i in range(0, len(self.options)):
            draw_text(screen, self.font, self.options[i], self.x+32, self.y+10 + i*line_space, COLOR_WHITE)
            i += 1

        screen.blit(self.pointer, (self.x+10, self.y+8 + self.current_option*line_space))


    # override
    def draw_run_state(self, screen: pygame.Surface) -> None:
        self._draw_options(screen)  
