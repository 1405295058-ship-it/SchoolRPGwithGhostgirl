extends Node

var next_spawn_id:String  = ""
var enter_animation_facing_dir:Vector2



var scene_path_map = {}

var pending_cg_animation := ""

func _ready() -> void:
	scene_path_map = {
	"Forecourt": "res://sence/场景/node_2d.tscn",
	"BoyAccommodationGF":"res://sence/场景/boy_accommodation_gf.tscn",
	"TeachingAreaGF":"res://sence/场景/school_building_fg.tscn",
	"CenterCampus":"res://sence/场景/center_campus.tscn",
	"Home_player_room":"res://sence/场景/home_bed_room.tscn"
	}
	

func change_scene_from_spawn(scene_id , spawn_id,enter_animation_facing_dir_):
	if get_tree().current_scene.scene_id == scene_id:
		return
	var scene_path = scene_path_map.get(scene_id,"")
	if scene_path == "" :
		push_error("这个scene_id写错了",scene_id,"发生在",spawn_id,"或者未将scene登录scene_path_map数据库")
		return
	next_spawn_id = spawn_id
	enter_animation_facing_dir = enter_animation_facing_dir_
	await FadeLayer.fade_out(0.5)
	get_tree().change_scene_to_file(scene_path)
	await FadeLayer.fade_in(0.5)

func change_scene_to_with_fade(scene_id:String):
	await FadeLayer.fade_out(0.5)
	await change_scene_to(scene_id)
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

func load_save_data(save_data: Dictionary) -> bool:
	var scene_data = save_data["scene_manager"]

	var scene_id = scene_data["scene_id"]
	var saved_position = scene_data["player_position"]

	if saved_position.size() != 2:
		push_error("玩家位置必须包含 x、y 两个数字")
		return false

	var target_position := Vector2(
		float(saved_position[0]),
		float(saved_position[1])
	)

	# 清除上一次普通传送或剧情切场景留下的数据
	next_spawn_id = ""
	enter_animation_facing_dir = Vector2.ZERO
	pending_cg_animation = ""

	await change_scene_to(scene_id)
	
	# 此时再找新场景里的玩家。
	var player := get_player_in_current_scene()

	if player == null:
		push_error("新场景中找不到 Player 分组里的玩家")
		return false

	player.global_position = target_position

	if player is CharacterBody2D:
		player.velocity = Vector2.ZERO

	return true

func get_save_data():
	var player = get_player_in_current_scene()
	
	var player_position = [
		player.global_position.x, 
		player.global_position.y
		]	
	
	var current_scene_id = get_tree().current_scene.scene_id
	
	return {
		"player_position": player_position,
		"scene_id": current_scene_id
	}


func get_player_in_current_scene() -> Node2D:
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return null

	for node in get_tree().get_nodes_in_group("player"):
		if not node is Node2D:
			continue

		if node == current_scene or current_scene.is_ancestor_of(node):
			return node as Node2D

	return null

func get_cg_director_in_current_scene():
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return null

	for node in get_tree().get_nodes_in_group("CGDirector"):
		if not node is Node2D:
			continue

		if node == current_scene or current_scene.is_ancestor_of(node):
			return node as Node2D

	return null
