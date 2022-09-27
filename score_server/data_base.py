import sqlite3
import random
import json
import collections

MAX_SCORES_PER_GAME = 50

def open_or_create(reset: bool):
    con = sqlite3.connect("scores.db")
    cur = con.cursor()

    if reset:
        cur.execute("DROP TABLE IF EXISTS games")
        cur.execute("DROP TABLE IF EXISTS game_scores")

    cur.execute("PRAGMA foreign_keys = ON")

    cur.execute('''
        CREATE TABLE IF NOT EXISTS games(
            id   INTEGER PRIMARY KEY,
            name TEXT    NOT NULL
        )
    ''')

    cur.execute('''
        CREATE TABLE IF NOT EXISTS game_scores(
            id      INTEGER PRIMARY KEY AUTOINCREMENT,
            game_id INTEGER NOT NULL,
            nick    TEXT    NOT NULL,
            score   INTEGER NOT NULL,
            date    TEXT    NOT NULL,

            FOREIGN KEY (game_id)
                REFERENCES games (id)
        )
    ''')
    con.close()


def get_connection():
    con = sqlite3.connect("scores.db")
    cur = con.cursor()
    cur.execute("PRAGMA foreign_keys = ON")
    return con, cur


def commit_and_close(con):
    con.commit()
    con.close()


def save_score(game_id, nick, score):
    con, cur = get_connection()
    cur.execute("INSERT INTO game_scores VALUES (NULL, %d, '%s', %d, datetime('now','localtime'))" % (game_id, nick, score, ))
    con.commit()

    cur.execute("SELECT COUNT(*) FROM game_scores")
    res = cur.fetchone()
    if res[0] > MAX_SCORES_PER_GAME:
        cur.execute("DELETE FROM game_scores WHERE score = (SELECT MIN(score) FROM game_scores) LIMIT 1")

    commit_and_close(con)


def is_highscore(game_id, score):
    con, cur = get_connection()

    cur.execute("SELECT COUNT(*) FROM game_scores")
    res = cur.fetchone()
    
    if res[0] < MAX_SCORES_PER_GAME:
        return True

    cur.execute("SELECT MIN(score) FROM game_scores WHERE game_id = %d" % (game_id))
    res = cur.fetchone()
    con.close()
    
    return score > res[0]

#    dict_list = []
#    for (name, score, dat) in tup_list:
#        entry = {}
#        entry['name'] = name
#        entry['score']= score
#        entry['date'] = dat
#        dict_list.append(entry)


def retrieve_leaderboard(game_id):
    con, cur = get_connection()

    cur.execute("""
        SELECT nick, score, date
            FROM game_scores
            WHERE game_id=%d 
            ORDER BY score DESC""" % (game_id))

    tup_list = cur.fetchall()

    dict_list = [{'name': name, 'score': score, 'date': dat} for name, score, dat in tup_list]

    con.close()
    return dict_list


def test_db():
    con = sqlite3.connect("scores.db")
    cur = con.cursor()

    cur.execute("PRAGMA foreign_keys = ON")
    
    cur.execute("INSERT INTO games VALUES ('%d','Duke Nukum')" % (1))
    cur.execute("INSERT INTO games VALUES ('%d','Duke Nukum II')" % (2))
    con.commit()
    
    for i in range(1,50):
        cur.execute("""
            INSERT INTO game_scores 
                VALUES (NULL, 1, %s, %d, datetime('now','localtime'))
        """ % ("'MAC'", random.randrange(500, 50000)))
        
    #cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'JOH', 485, datetime('now','localtime'))")
    #cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'JAK', 485, datetime('now','localtime'))")
    #cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'JDK', 95685, datetime('now','localtime'))")
    #cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'BRU', 195685, datetime('now','localtime'))")
    con.commit()

    res = cur.execute("SELECT name FROM sqlite_master")
    print(res.fetchone())
    print(res.fetchone())
    print(res.fetchone())

    con.close()


if __name__ == "__main__":
    open_or_create(True)
    test_db()
#    save_score(1, 'foo-bar', 1234)
    print(is_highscore(1, 65))
    retrieve_leaderboard(1)