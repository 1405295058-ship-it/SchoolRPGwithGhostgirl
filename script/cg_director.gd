#CGDirector
extends Node2D

@export var ID := "CGDirector"
@export_file("*.json") var cg_dialog_database_path = ""

var cg_dialog_database = {}

@onready var animation_player := $AnimationPlayer
var played_once = {}


var can_skipping := true
var is_skipping := false
var normal_speed := 1.0
var skip_speed := 10.0

func _ready() -> void:
	cg_dialog_database = load_file_from_json(cg_dialog_database_path)
	EventBus.play_this_animation.connect(play_animation)
	


func _process(delta: float) -> void:
	update_fast_forward()

func play_animation(anim_name:String, is_play_once_only := false):
	if played_once and played_once.get(anim_name, false):
		return
	if animation_player.is_playing():
		return
	# 再播放动画
	animation_player.play(anim_name)
	# 强制立即应用动画0秒的所有属性关键帧
	animation_player.advance(0.0)
	EventBus.start_play_cg.emit()
	await animation_player.animation_finished
	EventBus.end_play_cg.emit(anim_name)




func start_cg_dialog(cg_dialog_name:String):
	print("开始播放cg")
	can_skipping = true
	EventBus.enable_fast_forward.emit(can_skipping)
	if not cg_dialog_database.has(cg_dialog_name):
		push_error("缺少这一段的cg_dialog: ", cg_dialog_name)
		return
	var cg_dialog = cg_dialog_database.get(cg_dialog_name,[])
	animation_player.pause()
	
	DialogBox.start_dialog([],cg_dialog)
	await EventBus.on_dialog_finished
	
	animation_player.play()
	


	
func load_file_from_json(path:String)->Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON不存在： ",path)
		return {}
	
	var text = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Json解析失败或者不是JSON文件:", path)
		return{}
	return data

func change_scene_when_cg_play(scene_id:String,next_cg_id:String):
	ban_fast_forward()
	SceneManager.change_scene_during_cg(scene_id,next_cg_id)

func update_fast_forward():
	if not animation_player.is_playing():
		return
	if not can_skipping:
		animation_player.speed_scale = normal_speed
		return
	
	if Input.is_action_pressed("Space_Button"):
		if not is_skipping:
			is_skipping = true
			EventBus.cg_start_fast_forward.emit()
		animation_player.speed_scale = skip_speed
	else:
		is_skipping = false
		animation_player.speed_scale = normal_speed
		

func switch_to_cg_camera():
	var player := get_tree().get_first_node_in_group("player")
	var cg_camera := get_tree().get_first_node_in_group("CGCamera")
	if cg_camera == null:
		push_error("这个场景没有CGCamera")
		return
	if player == null:
		push_error("这个场景没有玩家")
		return
	player.disable_player_camera()
	cg_camera.enabled = true
	cg_camera.make_current()
	
	
	
	
func switch_to_player_camera():
	var player := get_tree().get_first_node_in_group("player")
	var cg_camera := get_tree().get_first_node_in_group("CGCamera")
	if cg_camera == null:
		push_error("这个场景没有CGCamera")
		return
	if player == null:
		push_error("这个场景没有玩家")
		return
	cg_camera.enabled = false
	player.enable_player_camera()
func cg_fade_in(time:float):
	FadeLayer.fade_in(time)	
func cg_fade_out(time:float):
	FadeLayer.fade_out(time)			
func start_with_black_screen():
	FadeLayer.set_black_screen()

func ban_fast_forward():
	can_skipping = false
	EventBus.enable_fast_forward.emit(can_skipping)

func hide_cg_fade_layer():
	NormalStateUi.hide_fade_layer()
