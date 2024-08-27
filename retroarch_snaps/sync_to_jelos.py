from locations import *
from io import TextIOWrapper
import os
import shutil

count: int = 1

def abs_rom_pc(system: str, game_file: str = '') -> str:
    return os.path.join(ROMS['pattern'] % ROMS['systems'][system], game_file)


def abs_rom_jelos(system: str, game_file: str = '') -> str:
    return os.path.join(os.path.join('E:\\', JELOS_THUMBS['systems'][system]), game_file)


def abs_thumbs_pc(system: str, game_file: str = '') -> str:
    thumb: str = os.path.splitext(game_file)[0] + '.png'
    return os.path.join(THUMBNAILS['pattern'] % THUMBNAILS['systems'][system], thumb)


def abs_thumbs_jelos(system: str, game_file: str = '') -> str:
    thumb: str = os.path.splitext(game_file)[0] + '.png'
    return os.path.join(os.path.join('E:\\', JELOS_THUMBS['systems'][system], 'images'), thumb)


def in_jelos_roms(system: str, game_file: str) -> bool:
    rom_folder: str = abs_rom_jelos(system)
    for rom in os.listdir(rom_folder):
        if game_file == rom:
            return True

    return False


def sync_rom_folder(system: str, exceptions: list[str]) -> None:
    xml_src: str = os.path.join(JELOS_THUMBS['dir'], JELOS_THUMBS['systems'][system], 'gamelist.xml')
    xml_dst: str = os.path.join(abs_rom_jelos(system), 'gamelist.xml')
    print('Copying xml from \'%s\' to \'%s\'' % (xml_src, xml_dst))
    shutil.copyfile(xml_src, xml_dst)

    if system in exceptions:
        print('System \'%s\' will not be synchronized. Skipping.' % system)
        return

    global count
    rom_folder: str = abs_rom_pc(system)
    for rom in os.listdir(rom_folder):
        if not os.path.isdir(os.path.join(rom_folder, rom)):

            # check which one is not in E:\ROMS (Jelos) folder
            if not in_jelos_roms(system, rom):
                print('Copying entry no. %d:' % count)

                rom_src: str = abs_rom_pc(system, rom)
                rom_dst: str = abs_rom_jelos(system, rom)
                print('  ROM   \'%s\' to \'%s\'' % (rom_src, rom_dst) )
                shutil.copyfile(rom_src, rom_dst)

                thumbs_src: str = abs_thumbs_pc(system, rom)
                thumbs_dst: str = abs_thumbs_jelos(system, rom)
                print('  THUMB \'%s\' to \'%s\'' % (thumbs_src, thumbs_dst) )
                shutil.copyfile(thumbs_src, thumbs_dst)

                count += 1



def sync_pc_to_jelos() -> None:
    # (call script to make JELOS thumbs)
    for key in ROMS['systems'].keys():
            sync_rom_folder(key, ['saturn', 'psx'])


if __name__ == '__main__':
    sync_pc_to_jelos()
