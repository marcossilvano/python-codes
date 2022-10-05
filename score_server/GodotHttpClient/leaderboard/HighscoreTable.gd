class_name HighscoreTable
extends VBoxContainer

signal table_loaded

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
	
	$ScoreServerHttpRequest.connect("request_completed", self, "_on_request_completed")
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
	
	$ScoreServerHttpRequest.make_request(url, json_str)		


func _show_error(msg: String) -> String:
	$LabelError.visible = true
	$LabelError.text = "ERROR: " + msg
	return msg


func _on_request_completed(json_dict: Dictionary) -> void:
	if json_dict:
		_fill_score_table(json_dict['data'])
	emit_signal("table_loaded")


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
		_show_error("Invalid table row: " + str(row))
		return Vector2.ZERO

	var pos = entries[row].get_position()
	pos.y += entries[row].get_rect().size.y/2 # get the y center
	return pos


func set_highlight(row: int) -> void:
	var entries = get_tree().get_nodes_in_group("highscore_entry")
	
	if row > entries.size() or row < 0:
		return
	
	target_entry = entries[row]
	target_entry.play_focus_animation()
