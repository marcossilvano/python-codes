extends Control


export var input_scene: PackedScene
export var scoretable_scene: PackedScene
export var camera_speed: float = 200

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

	current_scene.set_highlight(20)
	
	# set the timer up
	timer.connect("timeout", self, "start_camera")
	timer.set_wait_time(1)
	timer.start()


func start_camera() -> void:
	var target_position: Vector2 = current_scene.get_entry_screen_position(20)
	target_position.y -= get_viewport_rect().size.y/2

	# camera should not move upwards
	if target_position.y > 0:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camera, "position", target_position, 0.2*20)
