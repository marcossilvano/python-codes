from re import I
from flask import Flask
import json
from data_base import *
from flask import request
from flask_cors import CORS
from utils import verify_hmac

app = Flask(__name__)

CORS(app)

with open("secret.txt", "r") as f:
    SECRET_KEY = f.readline().strip()

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

def check_hash(key : str, hash : str, *data):
    data = "".join([str(i) for i in data])
    if not verify_hmac(data, key, hash):
        return json.dumps({
            'status' : 'fail',
            'data' : 'invalid request!'
        })
    return None

@app.get("/send_score/<int:game_id>/<string:nick>/<int:score>/<string:hash>")
def send_score_GET(game_id: int, nick: str, score: int, hash : str):
    game_id = int(game_id)
    score = int(score)
    
    hash_error = check_hash(SECRET_KEY, hash, game_id, nick, score)
    if hash_error is not None:
        return hash_error

    nick = nick.replace('%', ' ')
    print(nick)
    if is_highscore(game_id, score):
        last_insert_row = save_score(game_id, nick, score)
        return json.dumps({
            'status': 'success',
            'data': str(last_insert_row)
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
