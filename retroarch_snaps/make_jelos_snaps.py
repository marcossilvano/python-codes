from locations import *
from io import TextIOWrapper
import os
import shutil


XML_GAME_ID = 1


def get_abs_path(folder: str, file: str) -> str:
    new_path: str = os.path.abspath(folder)
    new_path: str = os.path.join(new_path, file)
    return new_path


def create_gamelist_file(dst_folder: str) -> TextIOWrapper:
    file: TextIOWrapper = open(os.path.join(dst_folder, 'gamelist.xml'), 'w')
    file.write('<?xml version="1.0"?>\n<gameList>\n')
    return file


def close_gamelist_file(file: TextIOWrapper) -> None:
    file.write('</gameList>')
    file.close()


def add_gamelist_entry(file: TextIOWrapper, game_file: str, game_image: str) -> None:
    global XML_GAME_ID
    file.write('    <game id="%d">\n' % XML_GAME_ID)
    file.write('        <path>./%s</path>\n' % ''.join(game_file))
    file.write('        <image>./images/%s</image>\n' % game_image)
    file.write('    </game>\n')

    XML_GAME_ID += 1


def get_rom_file(game_name: str, roms_folder: str) -> tuple[str, str]:
    for entry in os.listdir(roms_folder):
        splitted: tuple[str,str] = os.path.splitext(entry)
        if splitted[0] == game_name:
            return splitted
    return 'None'


def convert_folder(src_folder: str, dst_folder: str, roms_folder: str, game_file_folder: str) -> None:
    os.makedirs(dst_folder, exist_ok=True)
    print(dst_folder)
    gamelist_file = create_gamelist_file(game_file_folder)

    print('  Converting \'%s\'' % src_folder)
    count: int = 0
    for game_img in os.listdir(src_folder):
        # separate name and extension, then copy into images folder with -image suffix
        # splitted: tuple[str,str] = os.path.splitext(game_img)
        # new_img: str = splitted[0] + '-image' + splitted[1]
        if not os.path.exists(os.path.join(dst_folder, game_img)):
            shutil.copyfile(os.path.join(src_folder, game_img), os.path.join(dst_folder, game_img))
            count += 1
        
        game_file: tuple[str,str] = get_rom_file(os.path.splitext(game_img)[0], roms_folder)
        add_gamelist_entry(gamelist_file, game_file, game_img)
        
    print('    %d files copied.' % count)
    
    print('    gamelist.xml created.')
    close_gamelist_file(gamelist_file)


def find_in_table(assoc_table: list[tuple[str,str]], target: str) -> tuple[str,str]:
    for tup in assoc_table:
        if target == tup[0]:
            return tup
        
    return None


def convert_into_jelos(thumbs: dict, jelos_thumbs, systems: list[str], force: bool = False) -> None:
    os.makedirs(jelos_thumbs['dir'], exist_ok=True)

    # loop through all thumbnail folders
    for key, entry in thumbs['systems'].items():
        if key in systems or systems[0] == '*':
            src_folder: str = thumbs['pattern'] % entry

            if jelos_thumbs['systems'].get(key) == None or ROMS['systems'].get(key) == None:
                print('   ERROR: could not find \'%s\' in JELOS or ROMS dicts' % key)

            dst_folder: str = jelos_thumbs['pattern'] % jelos_thumbs['systems'][key]
            roms_folder: str = ROMS['pattern'] % ROMS['systems'][key]
            game_file_folder: str = jelos_thumbs['dir'] + '\\' + jelos_thumbs['systems'][key]
            
            if not os.path.exists(dst_folder) or force:
                convert_folder(src_folder, dst_folder, roms_folder, game_file_folder)
            else:
                print('\'%s\' already exists. Skipping.' % dst_folder)

if __name__ == '__main__':
    convert_into_jelos(THUMBNAILS, JELOS_THUMBS, ['*'], force=True)