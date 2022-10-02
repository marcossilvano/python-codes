extends Control


export var input_scene: PackedScene
export var scoretable_scene: PackedScene
export var speed_scale: float = 1
export var focus_on_row: int = 20

var current_scene: Node
onready var camera: Camera2D = $Camera2D
onready var timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = scoretable_scene.instance()
	add_child(current_scene)
	current_scene.connect("request_completed", self, "_on_table_loaded")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	var offset: Vector2 = Vector2(camera.position.x, camera_speed * delta)
#	camera.position += offset
	
	
func _on_table_loaded() -> void:
	print("TABLE LOADED")

	current_scene.set_highlight(focus_on_row)
	
	# set the timer up
	timer.connect("timeout", self, "start_camera")
	timer.set_wait_time(1)
	timer.start()


func start_camera() -> void:
	var screen_height: int = get_viewport_rect().size.y
	
	var target_position: Vector2 = current_scene.get_entry_screen_position(focus_on_row)
	target_position.y -= screen_height/2

	if target_position.y > (current_scene.rect_size.y - screen_height + 50):
		target_position.y = current_scene.rect_size.y - screen_height + 50
		
	#print("TABLE SIZE Y: " + str(current_scene.rect_size.y))

	# camera should not move upwards
	if target_position.y > 0:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camera, "position", target_position, 0.2*focus_on_row*1/speed_scale)
