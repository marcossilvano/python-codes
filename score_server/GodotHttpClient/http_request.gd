extends Node2D

onready var address: TextEdit = $CanvasLayer/TextAddress
onready var response: TextEdit = $CanvasLayer/TextResponse

onready var send_game_id: TextEdit = $CanvasLayer/TextGameId
onready var send_nick: TextEdit = $CanvasLayer/TextNick
onready var send_score: TextEdit = $CanvasLayer/TextScore

var _url: String

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

	

func _on_request_completed(result, response_code, headers, body):
	response.text = 'url: ' + _url + '\ncode: ' + str(response_code) + '\nbody: ' + body.get_string_from_utf8()
	
	var res_str: String
	if response_code == 200:
		var parsed_json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
		
		if parsed_json.error == OK:
			#parsed_json = JSON.parse('{"status": "success"}')
			
			# check for parse format and error
			if typeof(parsed_json.result) == TYPE_DICTIONARY:
				res_str = parsed_json.result['status']
			elif typeof(parsed_json.result) == TYPE_ARRAY:
				pass
			else:
				res_str = "ERROR: JSON response should be a dictionary or an array"
		else:
			res_str = "ERROR: JSON response parse error"
	else:
		res_str = "ERROR: The requested URL could not be retrieved"
		
	response.text = response.text + '\n\nRESPONSE:\n  ' + res_str


# send score
func _on_ButtonSendScore_pressed() -> void:
	
	#/send_score/<int:game_id>/<string:nick>/<int:score>
	var nick: String = send_nick.text.replace(' ', '%20')
	_url = address.text + '/send_score/' + send_game_id.text + '/' + nick + '/' + send_score.text
	
	print(name + ': send_score ' + _url)
	$HTTPRequest.request(_url)
