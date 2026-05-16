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


func _ready():
	await get_tree().process_frame
	set_up_player_in_spawn()
	_setup_camera_limit()
	GameStateManager.load_record()

func set_up_player_in_spawn():
	var spawn_id = SceneManager.next_spawn_id
	var should_face_dir = SceneManager.enter_animation_facing_dir
	if spawn_id == "":
		return
	
	var choose_spawn = null
	
	for spawn in get_tree().get_nodes_in_group("ChangeSceneArea"):
		if spawn.spawn_id == spawn_id:
			choose_spawn = spawn
			break
	
	if choose_spawn == null:
		push_warning("No spawn found: " + spawn_id)
		return
	
	player.global_position = choose_spawn.get_node("StartMarker2D").global_position
	player.face_dir = should_face_dir 



func _setup_camera_limit():
	camera.limit_left = camera_limit_left
	camera.limit_top = camera_limit_top
	camera.limit_right = camera_limit_right
	camera.limit_bottom = camera_limit_bottom
