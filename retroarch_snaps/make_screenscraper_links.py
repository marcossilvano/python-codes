import os
import csv

FILE = 'C:\\Users\\marko\\Downloads\\gameslist_nes.csv'

LINK = 'https://screenscraper.fr/gameinfos.php?gameid=%s&action=onglet&zone=gameinfosroms'

if __name__ == '__main__':
    new_path: str = os.path.splitext(FILE)[0] + '_links.csv'
    out = open(new_path, 'w', encoding='utf8')
    file = open(FILE, 'r', encoding='utf8')
    csv_file = csv.reader(file)
    for line in csv_file:
        entry: list[str] = line[0].split(';')
        print(entry)
        out.write('%-30s' % entry[1][1 : len(entry[1])-1])
        out.write('; ')
        out.write(LINK % entry[0])
        out.write('\n')

    print('\nFile \'%s\' written.' % new_path)
    file.close()
    out.close()
