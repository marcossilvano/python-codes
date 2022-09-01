from re import I
from flask import Flask
import json
from data_base import *

app = Flask(__name__)

@app.route("/send_score/<int:game_id>/<string:nick>/<int:score>")
def send_score(game_id: int, nick: str, score: int) -> None:
    if is_highscore(game_id, score):
        save_score(game_id, nick, score)
        return "score saved"
    else:
        return "not a highscore"


@app.route("/get_leaderboard/<int:game_id>")
def get_leaderboard(game_id: int):
    return json.dumps(retrieve_leaderboard(game_id))


@app.route("/check_highscore/<int:game_id>/<int:score>")
def check_highscore(game_id: int, score: int):
    return json.dumps(is_highscore(game_id, score))
