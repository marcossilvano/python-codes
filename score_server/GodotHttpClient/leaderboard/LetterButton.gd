class_name LetterButton
extends Button


export var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var current_letter = 0
var original_color: Color
var press_delay: float = 0

onready var arrow_up = $ArrowUp
onready var arrow_down = $ArrowDown
onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_color = modulate
	text = letters[current_letter]
	set_selected(false)
	

func show_arrows(visible: bool):
	arrow_up.visible = visible
	arrow_down.visible = visible
	if visible:
		animation_player.play("Arrows")
	else:
		animation_player.stop(true)
	

func set_selected(selected: bool):
	var color: Color = modulate
	
	if selected:
		color = Color(1.0, 1.0, 1.0, 1.0)
	else:
		color = original_color

	modulate = color
	show_arrows(selected)
	

func _on_Button_focus_entered():
	press_delay = 0
	set_selected(true)
	
	
func _on_Button_focus_exited() -> void:
	set_selected(false)


func wrap_around(n: float, left: int, right: int) -> float:
	if n < left: 
		n = right
	elif n > right: 
		n = left	
	return n
		

func reached_press_delay() -> bool:
	if (press_delay == 0):
		press_delay += 10 * get_process_delta_time()
		return true
	
	press_delay += 10 * get_process_delta_time()
	
	# time needed to hold the key so the letters will start rolling
	if (press_delay > 1.5):
		press_delay -= 1
		return true
	
	return false


func _on_Button_gui_input(event: InputEvent) -> void:
	if !has_focus():
		return
	
	# mouse clicked
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT && event.is_pressed():
		current_letter += 1
	
	if Input.is_action_pressed("ui_up"):
		if reached_press_delay():
			current_letter -= 1
	elif Input.is_action_pressed("ui_down"):
		if reached_press_delay():
			current_letter += 1
	else:
		press_delay = 0

	current_letter = wrap_around(current_letter, 0, len(letters)-1)
	text = letters[current_letter]
