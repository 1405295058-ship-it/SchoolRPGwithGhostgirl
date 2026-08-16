extends Node

var next_spawn_id:String  = ""
var enter_animation_facing_dir:Vector2



var scene_path_map = {}

var pending_cg_animation := ""

func _ready() -> void:
	scene_path_map = {
	"Forecourt": "res://sence/场景/node_2d.tscn",
	"BoyAccommodationGF":"res://sence/场景/boy_accommodation_gf.tscn",
	"TeachingAreaGF":"res://sence/场景/school_building_fg.tscn"
	}
	

func change_scene_from_spawn(scene_id , spawn_id,enter_animation_facing_dir_):
	if get_tree().current_scene.scene_id == scene_id:
		return
	var scene_path = scene_path_map.get(scene_id,"")
	if scene_path == "" :
		push_error("这个scene_id写错了",scene_id,"发生在",spawn_id)
		return
	next_spawn_id = spawn_id
	enter_animation_facing_dir = enter_animation_facing_dir_
	await FadeLayer.fade_out(0.5)
	get_tree().change_scene_to_file(scene_path)
	await FadeLayer.fade_in(0.5)

func change_scene_to_with_fade(scene_id:String):
	await FadeLayer.fade_out(0.5)
	change_scene_to(scene_id)
	await FadeLayer.fade_in(0.5)

func change_scene_to(scene_id:String):
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.scene_id == scene_id:
		return
	next_spawn_id = ""
	enter_animation_facing_dir = Vector2.ZERO
	var scene_path: String = scene_path_map.get(scene_id, "")
	if scene_path.is_empty():
		push_error("这个 scene_id 写错了：" + scene_id)
		return
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("切换场景失败：" + scene_id)
		return
	# 等待 SceneTree 真正完成场景替换
	await get_tree().process_frame
	# 更保险：确认目标场景真的已经成为 current_scene
	while get_tree().current_scene == null:
		await get_tree().process_frame
	while get_tree().current_scene.scene_id != scene_id:
		await get_tree().process_frame

	
func change_scene_during_cg(scene_id:String,next_cg_id:String):
	if get_tree().current_scene.scene_id == scene_id:
		return
	next_spawn_id = ""
	enter_animation_facing_dir= Vector2.ZERO
	pending_cg_animation = next_cg_id
	var scene_path = scene_path_map.get(scene_id,"")
	if scene_path == "" :
		push_error("这个scene_id写错了",scene_id)
		return
	await FadeLayer.fade_out(0.5)
	get_tree().change_scene_to_file(scene_path)

func continue_pending_cg():
	if pending_cg_animation == "":
		return
	EventBus.play_this_animation.emit(pending_cg_animation,true)
	pending_cg_animation = ""
