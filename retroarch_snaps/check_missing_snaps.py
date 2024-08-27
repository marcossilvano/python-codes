import os
import sys
import shutil

should_move_files: bool = False

def get_filenames(path: str) -> list[str]:
    content: list[str] = os.listdir(path)
    file_names: list[str] = []

    for item in content:
        if os.path.splitext(item)[1] != '.xml':
            filename = os.path.splitext(os.path.basename(item))[0] # remove extension
            file_names.append(filename)

    return file_names

def get_diff(roms_path: str, imgs_path: str) -> list[str]:
    folderA: list[str] = get_filenames(roms_path)
    # print(folderA)
    folderB: list[str] = get_filenames(imgs_path)

    diff: list[str] = [x for x in folderA if x not in folderB and not os.path.isdir(os.path.join(roms_path, x))]

    print('Exclusive to \'%s\' (%d):' % (roms_path, len(diff)))   
    if len(diff) == 0:
        print('   Nothing exclusive to folder.\n')
        return diff
    
    count: int = 1
    for name in diff:
        print('   %-3d %s' % (count, name))
        count += 1
    print()
    return diff

def move_diff_roms_into_new_folder(roms_path: str, diff_roms: list[str]) -> None:

    print('Moving roms without art into \'NEW\' subfolder:')
    new_folder: str = os.path.abspath(os.path.join(roms_path, 'NEW'))
    
    print('   Creating subfolder: %s.' % new_folder, end='')
    if not os.path.exists(new_folder):
        print(' Folder created.')
        os.mkdir(new_folder)
    else:
        print(' Folder already exists.')

    roms_path = os.path.abspath(roms_path)
    roms = os.listdir(roms_path)    # get original file names
    nothing: bool = True
    for name in diff_roms:
        for file in roms:
            if name != 'NEW' and name == os.path.splitext(os.path.basename(file))[0]:
                src: str = os.path.join(roms_path, os.path.basename(file)) 
                if not os.path.isfile(src): 
                    continue

                dst: str = os.path.join(new_folder,os.path.basename(file)) 
                print('   %s' % os.path.abspath(dst))
                os.rename(src, dst)
                nothing = False
    if nothing:
        print('   Nothing to move...')



def list_files(roms_path: str, imgs_path: str) -> None:
    print('----------------------------------------------------------------------')
    print('Cheking folders:\n   ROMS:  %s\n   SNAPS: %s' % (roms_path, imgs_path))

    if not os.path.exists(roms_path):
        print('\n*ERROR* Folder not found: \'%s\'\n' % roms_path)
        return
    if not os.path.exists(imgs_path):
        print('\n*ERROR* Folder not found: \'%s\'\n' % imgs_path)
        return

    print()
    diff_roms: list[str]= get_diff(roms_path, imgs_path)
    # diff_imgs: list[str] = print_diff(imgs_path, roms_path)

    if len(diff_roms) > 0:
        if input("Do you want to move these missing roms into a separate folder?\n   > ").lower() in ['y','yes']:
            # move all roms without box art into NEW subfolder
            move_diff_roms_into_new_folder(roms_path, diff_roms)

    print()
    #print(os.listdir(imgs_path))


def check_all(folders) -> None:
    for entry in folders["folders_map"]:
        list_files(folders['roms_dir'] % entry[0], folders['snaps_dir'] % entry[1])


def check_by_params() -> None:
    if '-move' in sys.argv: 
        sys.argv.remove('-move')
        global should_move_files
        should_move_files = True

    if (len(sys.argv) != 3):
        print("usage: python compare.py 'roms folder' 'images folder' [-move]")
        exit()

    list_files(sys.argv[1], sys.argv[2])
    # list_files('folderB', 'folderA')    


RETROARCH = {
    "roms_dir": 'D:\\Games\\%s',
    "snaps_dir": 'D:\\Games\\_thumbnails\\%s\\Named_Snaps',
    "folders_map": [
        # ROMS FOLDER  |  SNAPS FOLDER
        ('Arcade', 'MAME'),
        ('Amiga', 'Commodore - Amiga'),
        ('Famicom', 'Nintendo - Nintendo Entertainment System'),
        ('Game Boy', 'Nintendo - Game Boy'),
        ('Game Boy Advance', 'Nintendo - Game Boy Advance'),
        ('Nintendo 64', 'Nintendo - Nintendo 64'),
        ('Game Gear', 'Sega - Game Gear'),
        ('Master System', 'Sega - Master System - Mark III'),
        ('Mega Drive', 'Sega - Mega Drive - Genesis'),
        ('SEGA CD', 'Sega - Mega-CD - Sega CD'),
        ('Saturn', 'Sega - Saturn'),
        ('Neo Geo', 'SNK - Neo Geo'),
        ('Playstation', 'Sony - PlayStation'),
        ('MSX', 'Microsoft - MSX2'),
        ('PC Engine', 'NEC - PC Engine - TurboGrafx 16'),
        ('PC Engine CD', 'NEC - PC Engine CD - TurboGrafx-CD'),
        ('Super Nintendo', 'Nintendo - Super Nintendo Entertainment System')
    ]
}

JELOS = {
    "roms_dir": 'E:\\%s',
    "snaps_dir": 'D:\\Games\\_thumbnails\\%s\\Named_Snaps',
    "folders_map": [
        # ROMS FOLDER  |  SNAPS FOLDER
        # ('amiga', 'Commodore - Amiga'),
        # ('nes', 'Nintendo - Nintendo Entertainment System'),
        # ('gb', 'Nintendo - Game Boy'),
        # ('gba', 'Nintendo - Game Boy Advance'),
        # ('n64', 'Nintendo - Nintendo 64'),
        # ('gamegear', 'Sega - Game Gear'),
        ('mastersystem', 'Sega - Master System - Mark III'),
        # ('genesis', 'Sega - Mega Drive - Genesis'),
        # ('segacd', 'Sega - Mega-CD - Sega CD'),
        # ('neogeo', 'SNK - Neo Geo'),
        # ('psx', 'Sony - PlayStation'),
        # ('msx', 'Microsoft - MSX2'),
        # ('pcengine', 'NEC - PC Engine - TurboGrafx 16'),
        # ('pcenginecd', 'NEC - PC Engine CD - TurboGrafx-CD'),
        # ('snes', 'Nintendo - Super Nintendo Entertainment System')
    ]
}

MUOS = {
    'roms_dir': 'E:\\ROMS\\%s',
    'snaps_dir': 'D:\\Games\\_thumbnails\\%s\\Named_Snaps',
    'folders_map': [
        # ROMS FOLDER  |  SNAPS FOLDER
        # ('Amiga', 'Commodore Amiga'),
        # ('FC', 'Nintendo NES-Famicom'),
        # ('GB', 'Nintendo Game Boy'),
        # ('GBA', 'Nintendo Game Boy Advance'),
        # ('GG', 'Sega Game Gear'),
        # ('MD', 'Sega Mega Drive - Genesis'),
        # ('SMS', 'Sega Master System'),
        # ('MDCD', 'Sega Mega-CD - Sega CD'),
        # ('MSX', 'Microsoft - MSX'),
        # ('N64', 'Nintendo N64'),
        # ('PCE', 'NEC PC Engine'),
        # ('PCECD', 'NEC - PC Engine CD - TurboGrafx-CD'), ???
        # ('SFC', 'Nintendo SNES-SFC'),
        # ('NEOGEO', 'SNK Neo Geo')
    ]
}

def main():
    # global should_move_files
    # should_move_files = True
    # check_all(JELOS)
    check_all(RETROARCH)

if __name__ == '__main__':   
    main()