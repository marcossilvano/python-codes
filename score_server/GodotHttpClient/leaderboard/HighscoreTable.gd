class_name HighscoreTable
extends VBoxContainer

signal request_completed

export var address: String = "http://127.0.0.1:5000"
export var game_id: int = 1
#export (String, FILE, "*.tscn") var entry_scn_path: String = "res://leaderboard/HighscoreEntry.tscn"
export var entry_scene: PackedScene

var target_entry: HighscoreEntry
var color_offset: float = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelPadding.visible = false
	
	# remove placeholder entries
	get_tree().call_group("highscore_entry", "queue_free")
	
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	_make_request()


func _log(text) -> void:
	print(str(text))


func _make_request() -> void:
	#/get_leaderboard/<int:game_id>
	var url: String = address + '/get_leaderboard'

	# Convert data to json string:
	var json_str: String = JSON.print({
		"game_id": game_id
	})
	
	_log("request: " + url + ", json: " + json_str)
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	$HTTPRequest.request(url, headers, false, HTTPClient.METHOD_POST, json_str)	
	

func _show_error(msg: String) -> String:
	$LabelError.visible = true
	$LabelError.text = "ERROR: " + msg
	return msg


func _on_request_completed(result, response_code, headers, body):
	_log("response: " + str(response_code)) #+ ", json: " + body.get_string_from_utf8())
	
	var res_str: String
	
	if response_code == 200:
		var parsed_json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
		
		if parsed_json.error == OK:
			# check for parse format and error
			if typeof(parsed_json.result) == TYPE_DICTIONARY:
				res_str = parsed_json.result['status']		
				_fill_score_table(parsed_json.result['data'])
			else:
				res_str = _show_error("JSON response should be a dictionary or an array")
		else:
			res_str = _show_error("JSON parse error")
	else:
		res_str = _show_error("The requested URL could not be retrieved")
		
	_log("result: " + res_str)
	
	emit_signal("request_completed")
	

func _fill_score_table(scores: Array) -> void:
	#var scene: PackedScene = preload("res://leaderboard/HighscoreEntry.tscn")
	
	var order: int = 1
	for score in scores:
		var entry: HighscoreEntry = entry_scene.instance()
		entry.set_values(order, score['name'], score['score'], "09/set")#score['date'])
		order += 1
		add_child(entry)
		
		var padding = $PanelPadding.duplicate()
		padding.visible = true
		add_child(padding)
	
	#_log(scores)
	
func get_entry_screen_position(row: int) -> Vector2:
	var entries = get_tree().get_nodes_in_group("highscore_entry")

	if row > entries.size() or row < 0:
		return Vector2.ZERO

	var pos = entries[row].get_position()
	pos.y += entries[row].get_rect().size.y/2 # get the y center
	return pos


func set_highlight(row: int) -> void:
	var entries = get_tree().get_nodes_in_group("highscore_entry")
	
	if row > entries.size() or row < 0:
		return
	
	target_entry = entries[row]
	#var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	#tween.tween_property(entries[row], "modulate", Color(1,0,0), 0.2)

func _process(delta: float) -> void:
	if not target_entry:
		return

	var color: Color = target_entry.modulate
	color.g += color_offset * delta
	
	if color.g > 1:
		color.g = 1
		color_offset = -color_offset
	elif color.g < 0:	
		color.g = 0
		color_offset = -color_offset
	
	target_entry.modulate = color#colorColor(1,0,0)
