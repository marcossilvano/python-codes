from PIL import Image
import os

FORCE_OVERRIDE: bool = False

def resize_image(image_path: str, new_path: str, scale: tuple[float], resample: Image.Resampling, crop: tuple[int,int,int,int] = (0,0,0,0)) -> bool:
    if not FORCE_OVERRIDE and os.path.exists(new_path):
        # print('   Already exists: \'%s\'' % new_path)
        return False
    
    try:
        img: Image = Image.open(image_path)
    except:
        print('   *ERROR* -> file \'%s\' not found.' % image_path)
        return False
    
    width, height = img.size
    
    # resize to 45%
    width = int(width * scale[0])
    height = int(height * scale[1])


    new_image: Image = Image.new("RGBA", (width+crop[2], height+crop[3]))
    resized: Image = img.resize((width, height), resample)
    new_image.paste(resized)    

    # resized = resized.crop((0+crop[0], 0+crop[1], width+crop[2], height+crop[3]))
    # new_image.show()

    try:
        os.makedirs(os.path.dirname(new_path), exist_ok=True)
        new_image.save(new_path)
        print('   Resized image saved to \'%s\'.' % new_path)
    except:
        print('   *ERROR* -> cannot save \'%s\'.' % new_path)
        return False
    return True


def build_abs_path(folder: str, file: str) -> str:
    new_path: str = os.path.abspath(folder)
    new_path: str = os.path.join(new_path, file)
    return new_path


def resize_all(snaps_dir: list[tuple[str]], scale: tuple[float], resample: Image.Resampling) -> None:
    for entry in snaps_dir:
        src_folder: str = SRC_FOLDER % entry[0]
        dst_folder: str = DST_FOLDER % entry[1]
        print('\nResizing from \'%s\' to \'%s\':' % (src_folder, dst_folder))
        count: int = 0
        index: int = 0
        for file in os.listdir(src_folder):
            img_path: str = src_folder + '\\' + file
            dst_path: str = dst_folder + '\\' + file
            # print('  original: %s' % img_path)
            # print('  resized:  %s' % dst_path)
            
            index += 1
            # print(' ',index, end='')
            count += int(resize_image(img_path, dst_path, scale, resample))
        print('   Found %d files in source dir. %d resized into destination dir' % (len(os.listdir(src_folder)), count))

        if count != 0:
            print('   <Press any key to continue>')


def resize_folder(folder_path: str, new_path: str, scale: tuple[float], resample: Image.Resampling, crop: tuple[int,int,int,int]) -> None:
    if not os.path.exists(new_path):
        os.makedirs(new_path, exist_ok=True)

    for file in os.listdir(folder_path):
        current_file: str = os.path.join(folder_path, os.path.basename(file))
        new_file: str = os.path.join(new_path, os.path.basename(file))
        resize_image(current_file, new_file, scale, resample, crop)


SRC_FOLDER = 'D:\\Games\\_thumbnails\\%s\\Named_Snaps'
DST_FOLDER = 'D:\\Games\\_thumbnails\\_MUOS\\info\\catalogue\\%s\\box'

SNAPS_TO_MUOS = [
    # _thumbnails   |   _MUOS
    ('Commodore - Amiga', 'Commodore Amiga'),
    ('MAME', 'Arcade'),
    ('Microsoft - MSX2', 'Microsoft - MSX'),

    ('NEC - PC Engine - TurboGrafx 16', 'NEC PC Engine'),
    ('NEC - PC Engine CD - TurboGrafx-CD', 'NEC PC Engine'),

    ('Nintendo - Nintendo Entertainment System', 'Nintendo NES-Famicom'),
    ('Nintendo - Super Nintendo Entertainment System', 'Nintendo SNES-SFC'),
    ('Nintendo - Game Boy', 'Nintendo Game Boy'),
    ('Nintendo - Game Boy Advance', 'Nintendo Game Boy Advance'),
    ('Nintendo - Nintendo 64', 'Nintendo N64'),

    ('Sega - Game Gear', 'Sega Game Gear'),
    ('Sega - Master System - Mark III', 'Sega Master System'),
    ('Sega - Mega Drive - Genesis', 'Sega Mega Drive - Genesis'),
    ('Sega - Mega-CD - Sega CD', 'Sega Mega CD - Sega CD'),
    ('Sega - Saturn', 'Sega Saturn'),
    
    ('SNK - Neo Geo', 'SNK Neo Geo'),
    ('Sony - PlayStation', 'Sony PlayStation')
]

# THUMBS_TO_SNAPS = [
    # ('Amiga', 'Commodore - Amiga'),
    # ('Famicom', 'Nintendo - Nintendo Entertainment System'),
    # ('Super Nintendo', 'Nintendo - Super Nintendo Entertainment System'),
    # ('Game Boy', 'Nintendo - Game Boy'),
    # ('Game Boy Advance', 'Nintendo - Game Boy Advance'),
    # ('Nintendo 64', 'Nintendo - Nintendo 64'),
    # ('Game Gear', 'Sega - Game Gear'),
    # ('Master System', 'Sega - Master System - Mark III'),
    # ('Mega Drive', 'Sega - Mega Drive - Genesis'),
    # ('SEGA CD', 'Sega - Mega-CD - Sega CD'),
    # ('Neo Geo', 'SNK - Neo Geo'),
    # ('Playstation', 'Sony - PlayStation'),
    # ('MSX', 'Microsoft - MSX2'),
    # ('PC Engine', 'NEC - PC Engine - TurboGrafx 16'),
    # ('PC Engine CD', 'NEC - PC Engine CD - TurboGrafx-CD')
# ]

def test_resample_types() -> None:
    icons = 'C:\\linux-handhelds\\icons\\Retro Systems\\Retro Systems\\system'
    resized = 'C:\\linux-handhelds\\icons\\Retro Systems\\Retro Systems\\tests'

    scale = (2, 2)
    # resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_near.png'), scale, Image.Resampling.NEAREST)
    # resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_bicu.png'), scale, Image.Resampling.BICUBIC)
    # resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_bili.png'), scale, Image.Resampling.BILINEAR)
    resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_box.png'), scale,  Image.Resampling.BOX, (0,0,15,15))
    # resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_hamm.png'), scale, Image.Resampling.HAMMING)
    # resize_image(os.path.join(icons, 'AMIGA.png'), os.path.join(resized, 'AMIGA_lanc.png'), scale, Image.Resampling.LANCZOS)

def resize_muos_system_icons() -> None:
    icons = 'C:\\linux-handhelds\\icons\\Retro Systems\\Retro Systems\\system'
    resized = 'C:\\linux-handhelds\\icons\\Retro Systems\\Retro Systems\\system_2x'
    resize_folder(icons, resized, (2,2), Image.Resampling.BOX, (0,0,15,15))

if __name__ == '__main__':
    # test_resample_types()
    resize_all(SNAPS_TO_MUOS, (0.45, 0.45), Image.Resampling.BICUBIC)
    # resize_muos_system_icons()