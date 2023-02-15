import sys, pygame
pygame.init()

class Ball:
    x = 0 # inutil?
    y = 0 # inutil?
    speed_x = 2
    speed_y = 2
    rect = None
    image = None

size = width, height = 1024, 768
black = (0, 0, 0)

screen = pygame.display.set_mode(size)

ball = Ball()
ball.image = pygame.image.load("intro_ball.gif")
ball.rect = ball.image.get_rect()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT: sys.exit()

    #ballrect = ballrect.move(speed)
    if ball.rect.left < 0 or ball.rect.right > width:
        ball.speed_x = -ball.speed_x
    if ball.rect.top < 0 or ball.rect.bottom > height:
        ball.speed_y = -ball.speed_y

    ball.rect.x = ball.rect.x + ball.speed_x
    ball.rect.y = ball.rect.y + ball.speed_y

    screen.fill(black)
    screen.blit(ball.image, ball.rect)
    pygame.display.flip()