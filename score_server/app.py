from flask import Flask

app = Flask(__name__)

@app.route("/send_score/<int:game_id>/<string:nick>/<int:score>")
def send_score(game_id, nick, score) -> None:
    print(game_id)
    print(nick)
    print(score)
    return "<p>score sent!</p>"

@app.route("/get_leaderboard")
def get_leaderboard():
    return "<p>here's your leaderboard!</p>"
