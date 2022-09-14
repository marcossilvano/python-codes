from re import I
from flask import Flask
import json
from data_base import *
from flask import request

app = Flask(__name__)


def decode_post_and_call(request_handler):
    json_dict = {}

    # extract json data sent as raw data or form inside the POST request
    if request.data:
        json_dict = json.JSONDecoder().decode(request.data.decode("utf-8"))

    if request.form:
        json_dict = request.form
    
    return request_handler(**json_dict)


@app.post("/send_score")
def send_score_POST():   
    return decode_post_and_call(send_score_GET)


@app.get("/send_score/<int:game_id>/<string:nick>/<int:score>")
def send_score_GET(game_id: int, nick: str, score: int):
    game_id = int(game_id)
    score = int(score)

    if is_highscore(game_id, score):
        save_score(game_id, nick, score)
        return json.dumps({
            'status': 'success'
        })
    else:
        return json.dumps({
            'status': 'fail',
            'data': 'is not highscore'
        })


@app.post("/get_leaderboard")
def get_leaderboard_POST():   
    return decode_post_and_call(get_leaderboard_GET)


@app.get("/get_leaderboard/<int:game_id>")
def get_leaderboard_GET(game_id: int):
    return json.dumps({
        'status': 'success',
        'data': retrieve_leaderboard(int(game_id))
    })


@app.post("/check_highscore")
def check_highscore_POST():
    return decode_post_and_call(check_highscore_GET)


@app.get("/check_highscore/<int:game_id>/<int:score>")
def check_highscore_GET(game_id: int, score: int):
    if is_highscore(int(game_id), score):    
        return json.dumps({
            'status': 'success',
            'data': 'true'
        })
    else:
        return json.dumps({
            'status': 'success',
            'data': 'false'
        })


@app.post("/get_leaderboard_length")
def get_leaderboard_length_POST():
    return decode_post_and_call(get_leaderboard_length_GET)


@app.get("/get_leaderboard_length")
def get_leaderboard_length_GET():
    return json.dumps({
        'status': 'success',
        'data': str(MAX_SCORES_PER_GAME)
    })