extends Control

@export var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var nick: Array

var original_color: Color

var buttons: Array
var current_button: int = 0
var last_button: int = 0
var letter_delay: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	buttons = get_tree().get_nodes_in_group("button_letter")
	
	for btn in buttons:
		#btn.connect("focus_entered", self, "button_focus_entered")
		#btn.connect("gui_input", self, "button_gui_input")
		btn.connect("gui_input", Callable(self, "_on_gui_input"))
		nick.append(0)
		
	original_color = buttons[0].modulate
	buttons[0].grab_focus()

	
func set_selected(button: Button, selected: bool):
	if !button:
		return
	
	var color: Color = button.modulate
	
	if selected:
		color = Color(1.0, 1.0, 1.0, 1.0)
	else:
		color = original_color

	button.modulate = color
	
	
func button_focus_entered():
	if last_button != current_button:
		letter_delay = 0
		
	set_selected(buttons[last_button], false)
	
	#print("entered " + get_focus_owner().name)
	set_selected(buttons[current_button], true)
	last_button = current_button
	
	buttons[current_button].grab_focus()
	
	#var button: Button = get_focus_owner()
	#button.get("custom_fonts/font").outline_size = 0


func wrap_around(n: float, left: int, right: int) -> float:
	if n < left: 
		n = right
	elif n > right: 
		n = left	
	
	return n


func reached_letter_delay(delta: float):
	if (letter_delay == 0):
		letter_delay += 4 * delta
		return true
	
	letter_delay += 4 * delta
	
	# time need to hold the key so the letters will start rolling
	if (letter_delay > 1.5):
		letter_delay -= 1
		return true
	return false


func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		if reached_letter_delay(_delta):
			nick[current_button] -= 1
	elif Input.is_action_pressed("ui_down"):
		if reached_letter_delay(_delta):
			nick[current_button] += 1
	else:
		letter_delay = 0

	nick[current_button] = wrap_around(nick[current_button], 0, len(letters)-1)
	
	if Input.is_action_just_pressed("ui_left"):
		current_button -= 1;
	elif Input.is_action_just_pressed("ui_right"):
		current_button += 1;
	
	if Input.is_mouse_button_pressed(0):
		current_button = 0
	
	current_button = wrap_around(current_button, 0, len(buttons)-1)		
	button_focus_entered()

	buttons[current_button].text = letters[nick[current_button]]
	
