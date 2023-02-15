extends Control

export var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?#@"

var nick_name: String
var buttons: Array


func _ready():
	buttons = get_tree().get_nodes_in_group("button_letter")
	
	for btn in buttons:
		btn.letters = letters
				
	buttons[0].grab_focus()


func build_nick_from_buttons() -> void:
	nick_name = ""
	for btn in buttons:
		nick_name += btn.text
