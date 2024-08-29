from data_base import open_or_create, commit_and_close, get_connection

iniciais = ["MEB", "GSF", "JVSS", "PBA", "DSG", "JMA", "VHGK", "WWTR", "GAL", "YUSB", "AF", "AMM", "FZ", "BCM", "MSA", "JHF", "OSEJ"]

if __name__ == "__main__":
    db = open_or_create(True)
    con, cur = get_connection()
    cur.execute("INSERT INTO games VALUES ('1','Chi-Ken')")
    for i, nick in enumerate(iniciais):
        cur.execute("INSERT INTO game_scores VALUES (NULL, 1, '%s', %d, datetime('now','localtime'))" % (nick, 100 + i))
        
    commit_and_close(con)
    print("Database reset.")

