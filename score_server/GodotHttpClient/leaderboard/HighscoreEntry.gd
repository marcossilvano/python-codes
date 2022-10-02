class_name HighscoreEntry
extends Control


func set_values(order: int, name: String, score: int, time: String) -> void:
	$PanelContainer/HBoxContainer/Order.text = str(order)
	$PanelContainer/HBoxContainer/Name.text = name
	$PanelContainer/HBoxContainer/Score.text = str(score)
	$PanelContainer/HBoxContainer/Time.text = time


func play_focus_animation() -> void:
	$AnimationPlayer.play("NewHighscore")
