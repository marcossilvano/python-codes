import sqlite3
import random

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
    cur.execute("INSERT INTO game_scores VALUES (NULL, %d, '%s', %d)" % (game_id, nick, score))
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


def test_db():
    con = sqlite3.connect("scores.db")
    cur = con.cursor()

    cur.execute("PRAGMA foreign_keys = ON")
    
    cur.execute("INSERT INTO games VALUES ('%d','Duke Nukum')" % (1))
    cur.execute("INSERT INTO games VALUES ('%d','Duke Nukum II')" % (2))
    con.commit()
    
    cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'john-doe', 485)")
    cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'jake', 485)")
    cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'joanna_dark', 95685)")
    cur.execute("INSERT INTO game_scores VALUES (NULL, 1, 'bruce_jane', 195685)")
    con.commit()

    res = cur.execute("SELECT name FROM sqlite_master")
    print(res.fetchone())
    print(res.fetchone())
    print(res.fetchone())

    con.close()


if __name__ == "__main__":
    open_or_create(True)
    test_db()
    save_score(1, 'foo-bar', 1234)
    print(is_highscore(1, 65))