'''
Space Blaster.

To activate VirtualEnv:
    $ source ../../venv-pygame/bin/activate

Add PyGame lib includes into Pylance extra paths
    ../../venv-pygame/lib/python3.10/site-packages
'''

import sys, pygame, time, copy

# ----- Constants -------

COLOR_BLACK = (0, 0, 0)
COLOR_GREEN = (0, 255, 0)

WIDTH = 1280
HEIGHT= WIDTH*(9/16)

SHIP_SPEED = 300

STATE_ALIVE = 0
STATE_DEAD  = 1

MOVE_H = 0
MOVE_V = 1

ANIM_MOVEMENT = 0
ANIM_EXPLODE  = 1
ANIM_LEFT     = 1
ANIM_RIGHT    = 2

TAG_SHIP  = 0
TAG_ENEMY = 0

levels=[
"""  
     X X       X X
       X X   X X  
         x x x 
       x x   x x
     x x       x x


     bbb  bbb  bbb
"""
]

# ------ Classes ---------

class Animation:
    total_frames = 0
    frame_duration = 0
    time_count  = 0
    curr_frame = 0
    curr_anim = 0
    anims = None

class GameObject:
    x = 0
    y = 0
    speed_x = 0
    speed_y = 0
    min_x = 0
    max_x = 0
    
    width = 0
    height= 0
    texture = None
    
    health = 0
    state = STATE_ALIVE    
    move = MOVE_H
    move_count = 0
    anim: Animation = None

    tag = 0
    fire_count = 0

# ------ Globals --------

ship: GameObject = None
enemies: list = None
bullets: list = None
shields: list = None

# ------- Logic ---------

def should_quit():
    for event in pygame.event.get():
        if event.type == pygame.QUIT: 
            return True
        
    return False


def get_time() -> None:
    time_curr = time.time() * 1000
    time_delay = 1000/60 - (time_curr - time_prev)
    time_prev = time_curr
    time_delay = max(int(time_delay), 0)


def create_game_object(x: int, y: int, scale: float, width, height,
                       texture: str = "", surface: pygame.Surface = None) -> GameObject:
    obj: GameObject = GameObject()
    if texture != "":
        obj.texture = pygame.image.load(texture)
    else:
        obj.texture = surface
    obj.rect = obj.texture.get_rect()
    
    obj.x = x
    obj.y = y
    obj.min_x = 0
    obj.max_x = WIDTH
    obj.width = width
    obj.height = height

    obj.anim = Animation()
    obj.anim.anims = []
    obj.anim.frame_duration = 0.3
    obj.anim.total_frames = obj.texture.get_rect().width // width

    scale_object(obj, scale)

    return obj


def scale_object(obj, scale=1):
    obj.texture = pygame.transform.scale_by(obj.texture, scale)
    obj.width *= scale
    obj.height*= scale


def keep_inside_bounds(obj):
    x_border = False
    y_border = False

    # limites X customizados
    if obj.x < obj.min_x:
        obj.x = obj.min_x
        x_border = True
    elif obj.x > obj.max_x:
        obj.x = obj.max_x
        x_border = True
    
    # limites Y da tela
    if obj.y < 0:
        obj.y = 0
        y_border = True
    elif obj.y > HEIGHT - obj.height:
        obj.y = HEIGHT - obj.height
        y_border = True

    return (x_border,y_border)


def set_animation(obj: GameObject, anim: int):
    # reassure anim index is ok
    anim = min(anim, len(obj.anim.anims))

    obj.anim.curr_anim = anim
    obj.anim.curr_frame = 0
    obj.anim.time_count = 0


def check_collision(obj1: GameObject, obj2: GameObject):
    if obj1.state == STATE_DEAD or obj2.state == STATE_DEAD:
        return False
    '''
      r1.left    <     r2.right   
        +------------+
        |     R1     |
        |      +----------+
        +------|-----+    |
               |    R2    |
               +----------+
           r2.left  <  r1.right
    '''
    r1 = pygame.Rect(obj1.x - obj1.width//2, obj1.y - obj1.height//2, obj1.width, obj1.height)
    r2 = pygame.Rect(obj2.x - obj2.width//2, obj2.y - obj2.height//2, obj2.width, obj2.height)

    if r1.x < (r2.x + r2.width-1)  and r2.x < (r1.x + r1.width-1) and \
       r1.y < (r2.y + r2.height-1) and r2.y < (r1.y + r1.height-1):
        return True

    return False


def check_collision_lists(list1, list2):
    for obj1 in list1:
        for obj2 in list2:
            if obj1.state == STATE_DEAD:
                continue

            if check_collision(obj1, obj2):
                set_animation(obj1, ANIM_EXPLODE)
                obj1.state = STATE_DEAD
                obj1.anim.frame_duration = 0.05
                
                set_animation(obj2, ANIM_EXPLODE)
                obj2.state = STATE_DEAD
                obj2.anim.frame_duration = 0.05
                return True
            
    return False


def blit_game_object(screen: pygame.Surface, obj: GameObject, dt: float):
    has_ended = False
    
    # animate
    obj.anim.time_count += dt
    if obj.anim.time_count >= obj.anim.frame_duration:
        obj.anim.time_count -= obj.anim.frame_duration
        obj.anim.curr_frame += 1
        obj.anim.curr_frame %= len(obj.anim.anims[obj.anim.curr_anim])

    # draw
    frame = obj.anim.anims[obj.anim.curr_anim][obj.anim.curr_frame]
    if frame == -1:
        obj.anim.curr_frame -= 1
        has_ended = True

    offset = obj.anim.anims[obj.anim.curr_anim][obj.anim.curr_frame]
    pos = (obj.x - obj.width//2, obj.y - obj.height//2)
    clip = (offset * obj.width,0,obj.width,obj.height)
    screen.blit(obj.texture, pos, clip)

    return has_ended


def blit_list(screen, list, dt):
    for obj in list.copy(): 
        has_ended = blit_game_object(screen, obj, dt)
        if obj.anim.curr_anim == ANIM_EXPLODE and has_ended:
            list.remove(obj)

#---- Create Entities ----

def create_bullet(x, y, speed_y, tag):
    bullet = create_game_object(x, y, 1.5, 10, 15, "textures/bullet_10x15.png")
    bullet.speed_x = 0
    bullet.speed_y = speed_y
    bullet.tag = tag
    bullet.anim.frame_duration = 0.05
    bullet.anim.anims.append([0,1]) # ANIM_MOVEMENT
    bullet.anim.anims.append([2,3,4,-1]) # ANIM_EXPLODE (-1=one shot)
    set_animation(bullet, ANIM_MOVEMENT)

    return bullet


def create_ship() -> GameObject:
    ship = create_game_object((WIDTH-64)/2, HEIGHT-50, 1.5, 32, 32, "textures/ship_32x32.png")
    ship.speed_x = SHIP_SPEED
    ship.speed_y = SHIP_SPEED
    ship.min_x = 100
    ship.max_x = WIDTH-100
    ship.anim.anims.append([0]) # ANIM_MOVEMENT
    ship.anim.anims.append([1]) # ANIM_LEFT
    ship.anim.anims.append([2]) # ANIM_RIGHT
    set_animation(ship, ANIM_MOVEMENT)
    
    return ship


def create_enemy(x, y, scale, surf):
    en = create_game_object(x, y, scale, 32, 32, surface=surf)
    en.speed_x = 100
    en.speed_y = 100
    en.min_x = en.x - 300
    en.max_x = en.x + 300
    en.anim.anims.append([0,1]) # ANIM_MOVEMENT
    en.anim.anims.append([2,3,4,5,-1]) # ANIM_EXPLOSION (-1=one shot)
    set_animation(en, ANIM_MOVEMENT)

    return en


def init_map(current_level):
    global enemies
    global shields

    padding_x = 50
    padding_y = 70

    enemy_texture = pygame.image.load("textures/enemy_purple_32x32.png")
    shield_texture= pygame.image.load("textures/shield_50x50.png")

    row = 0
    col = 0
    level_str = levels[current_level]
    
    # cria os inimigos baseado no mapa do level
    for ch in level_str:
        match ch:
            case '\n': 
                row += 1
                col = 0
            case 'x':
                enemies.append(create_enemy(col*padding_x + padding_x/2, row*padding_y, 1.5, enemy_texture))
            case 'X':
                enemies.append(create_enemy(col*padding_x + padding_x/2, row*padding_y, 2.0, enemy_texture))
            case 'b':
                shield = create_game_object(col*padding_x + padding_x/2, row*padding_y, 1.0, 50, 50, surface=shield_texture)
                shield.anim.anims.append([0]) #ANIM_MOVEMENT
                shield.anim.anims.append([1,2,3,-1]) #ANIM_EXPLOSION
                shields.append(shield)

        col += 1

#----- Update Entities Logic -----

def update_ship(keys, dt):
    global ship
    
    if ship.state == STATE_DEAD:
        return
    
    ship.speed_x = 0
    set_animation(ship, ANIM_MOVEMENT)
    
    if keys[pygame.K_d]:
        ship.speed_x = SHIP_SPEED
        set_animation(ship, ANIM_RIGHT)
    elif keys[pygame.K_a]:
        ship.speed_x = -SHIP_SPEED
        set_animation(ship, ANIM_LEFT)

    ship.fire_count += dt
    if keys[pygame.K_w]:
        if ship.fire_count >= 0.3:
            ship.fire_count = 0
            bullets.append(create_bullet(ship.x, ship.y, -700, TAG_ENEMY))

    ship.x = ship.x + ship.speed_x * dt

    keep_inside_bounds(ship)


def update_enemies(dt):
    global enemies

    for en in enemies:
        if en.state == STATE_DEAD:
            continue

        if en.move == MOVE_H:
            en.x = en.x + en.speed_x * dt
            
            bounds = keep_inside_bounds(en)
            if bounds[0]:
                en.speed_x = -en.speed_x
                en.move = MOVE_V
                en.move_count = 0

        if en.move == MOVE_V:
            en.y = en.y + en.speed_y * dt
            en.move_count += dt

            if en.move_count >= 0.3:
                en.move_count = 0
                en.move = MOVE_H


def update_bullets(dt):
    global bullets

    for bul in bullets:
        if bul.state == STATE_DEAD: 
            continue

        bul.y = bul.y + bul.speed_y * dt
        
        bounds = keep_inside_bounds(bul)
        if bounds[1]:
            bullets.remove(bul)

# ----------- MAIN --------------

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.FULLSCREEN | pygame.SCALED)
    pygame.display.set_caption("Ball PyGame Example")
    
    global ship 
    global enemies
    global bullets
    global shields

    level = 0
    ship = create_ship()
    enemies = []
    shields = []
    init_map(level)
    bullets = []

    clock = pygame.time.Clock()
    time_prev = time.time() * 1000

    font = pygame.font.Font('Coders_Crux.ttf', 32)
    text_fps = font.render('HUD', False, COLOR_GREEN)
    text_rect= text_fps.get_rect()
    text_rect.topleft = (10,10)
    dt = 0

    rotation = 0.0

    # Game Loop
    while not should_quit():
        keys = pygame.key.get_pressed()
        if keys[pygame.K_ESCAPE]: break
        #get_time()

        # --- Update Logic ---
        update_ship(keys, dt)
        update_enemies(dt)
        update_bullets(dt)

        # ---- Collisions ----
        check_collision_lists(bullets, shields)
        check_collision_lists(bullets, enemies)

        # --- Render Frame ---
        screen.fill(COLOR_BLACK)

        blit_list(screen, bullets, dt)
        blit_game_object(screen, ship, dt)
        blit_list(screen, enemies, dt)
        blit_list(screen, shields, dt)

        text_fps = font.render('FPS: %d  Enemies: %d  Bulles: %d ' %
                               (clock.get_fps(), len(enemies), len(bullets)), 
                               False, COLOR_GREEN)
        screen.blit(text_fps, text_rect)
        
        pygame.display.flip()

        # --- Keep Sync ---
        dt = clock.tick()/1000 # (60)
        #pygame.time.delay(time_delay)

    sys.exit()


if __name__ == '__main__':
    main()