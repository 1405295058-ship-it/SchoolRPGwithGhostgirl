extends Node2D

@export var scene_name:String =  ""
@export var scene_id:String =  ""


@export var camera_limit_left: int
@export var camera_limit_top: int
@export var camera_limit_right: int
@export var camera_limit_bottom: int


@onready var animation_sprite = $Player/AnimatedSprite2D
@onready var player = $Player
@onready var camera = $Player/Camera2D
var choose_spawn:Node 
var canvas_modulate:CanvasModulate 


func _ready():
	await get_tree().process_frame
	set_up_player_in_spawn()
	_setup_camera_limit(player)
	EventBus.scene_changed.emit()
	find_canvas_modulate()
	EnvironmentLayer.register_canvas_modulate(canvas_modulate)
	SceneManager.continue_pending_cg()
func set_up_player_in_spawn():
	var spawn_id = SceneManager.next_spawn_id
	var should_face_dir = SceneManager.enter_animation_facing_dir
	if should_face_dir == Vector2.ZERO:
		return
	if spawn_id == "":
		return
	
	choose_spawn = null
	
	for spawn in get_tree().get_nodes_in_group("ChangeSceneArea"):
		if spawn.ID == spawn_id:
			choose_spawn = spawn
			break
	
	if choose_spawn == null:
		push_warning("No spawn found: " + spawn_id)
		return
	
	player.global_position = choose_spawn.get_node("StartMarker2D").global_position
	player.face_dir = should_face_dir 

func find_canvas_modulate():
	for child in get_children():
		if child is CanvasModulate:
			canvas_modulate = child
			return
	
	print("这个场景没有CanvasModulate")

func _setup_camera_limit(player:Player):
	player.camera.limit_left = camera_limit_left
	player.camera.limit_top = camera_limit_top
	player.camera.limit_right = camera_limit_right
	player.camera.limit_bottom = camera_limit_bottom
