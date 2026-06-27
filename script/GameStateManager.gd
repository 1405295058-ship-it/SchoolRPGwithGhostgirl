extends Node

var scene_map = {}

const WORLD_STATE_PATH:="res://QuestResources/WorldStateControl/WorldStateFile.json"
const EVENT_STATE_PATH:="res://QuestResources/WorldStateControl/EventStateFile.json"
const DEFULT_OBJECT_SCHEDULE_PATH:="res://QuestResources/WorldStateControl/DefaultObjectScheduleFile.json"

var current_changed_record = {
	"Forecourt":{
					
			},
		
		
	
	"TeachingAreaGF":{}
	
	
					}

#"morning",
#	"lunch_time",
#	"dinner_time",
#	"night_time"
var default_object_schedule := {}
var event_state := {}
var world_state := {}


func _ready() -> void:
	EventBus.change_day_period.connect(_on_day_period_changed)
	EventBus.a_quest_finished.connect(_on_quest_finished)
	EventBus.a_quest_state_finished.connect(_on_quest_state_finish)
	EventBus.unlocked_quest_world_should_apply.connect(_on_unlocked_quest_world_should_apply)
	EventBus.scene_changed.connect(_on_scene_changed)
	
	world_state = load_file_from_json(WORLD_STATE_PATH)
	event_state = load_file_from_json(EVENT_STATE_PATH)
	default_object_schedule = load_file_from_json(DEFULT_OBJECT_SCHEDULE_PATH)
	
	
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


func _on_scene_changed():
	refresh_scene_state()	
	
func _on_quest_finished(_quest_name)->void:
	refresh_scene_state()

func _on_quest_state_finish(quest_name:String,current_state_str:String)->void:
	event_and_world_state_update(quest_name,current_state_str)	

func _on_day_period_changed()->void:
	call_deferred("refresh_scene_state")
	
func _on_unlocked_quest_world_should_apply(quest_name)->void:
	event_and_world_state_update(quest_name,"unactive")
	
#一个需要刷新的总和
func refresh_scene_state():
	erase_current_scene_record()
	load_defult_objects_in_current_scene()
	apply_current_quest_states()
	load_record()
	print("record是： ",current_changed_record)
	
func erase_current_scene_record():
	var current_scene_name = get_tree().current_scene.name

	if not current_changed_record.has(current_scene_name):
		current_changed_record[current_scene_name] = {}
		return

	for object_id in current_changed_record[current_scene_name].keys():
		current_changed_record[current_scene_name][object_id]["change"] = {}
func apply_current_quest_states():
	for quest_name in QuestManager.quest_progress_data.keys():
		var quest_data = QuestManager.quest_progress_data[quest_name]
		var status = quest_data["quest_progress_status"]
		var current_state_str = str(quest_data["current_state"])

		if status == QuestManager.quest_progress_status.active:
			event_and_world_state_update(quest_name, current_state_str)

		elif status == QuestManager.quest_progress_status.unlock:
			event_and_world_state_update(quest_name, "unactive")

func event_and_world_state_update(quest_name,current_state_str):
	event_state_update(quest_name,current_state_str)
	world_state_update(quest_name,current_state_str)
func event_state_update(quest_name,current_state_str):
	if not event_state.has(quest_name):
		return
	
	if not event_state[quest_name].has("quest_states"):
		return
	
	if not event_state[quest_name]["quest_states"].has(current_state_str):
		return
		
	var current_actions = event_state[quest_name]["quest_states"][current_state_str]
	
	
	for action in current_actions :
		
		process_action_and_change(action,"action")
		write_record(action,"action")
		

func world_state_update(quest_name,current_state_str):

	
	if not world_state.has(quest_name):
		return
	
	if not world_state[quest_name].has("quest_states"):
		return
	
	if not world_state[quest_name]["quest_states"].has(current_state_str):
		return
	
	var current_changes = world_state[quest_name]["quest_states"][current_state_str]
	
	
	for change_information in current_changes:
		process_action_and_change(change_information ,"change")
		write_record(change_information,"change")
		print(current_changed_record )

		
func find_things_in_scene_byID(group:String,ID:String):
	for obj in get_tree().get_nodes_in_group(group):
		if obj.ID == ID:
			return obj
	return null

func should_follow(ID:String,group:String,action:Dictionary):
	if  action["action"].has("following"):
		var enable = action["action"]["following"]["enable"]
		var target_ID = action["action"]["following"]["target_ID"]
		var target_group = action["action"]["following"]["target_group"]
		var obj = find_things_in_scene_byID(group,ID)
		if obj == null:
			return
		obj.following = enable
		obj.follow_ID = target_ID
		obj.follow_group = target_group
		
		


func write_record(save: Dictionary, action_or_change: String):
	if not save.has("scene"):
		print("缺少 scene")
		return
	if not save.has("object_ID"):
		print("缺少 object_ID")
		return
	if not save.has("group"):
		print("缺少 group")
		return

	if action_or_change != "action" and action_or_change != "change":
		print("action_or_change 必须是 action 或 change")
		return

	var scene_name = save["scene"]
	var object_id = save["object_ID"]
	var group = save["group"]

	if not current_changed_record.has(scene_name):
		current_changed_record[scene_name] = {}

	if not current_changed_record[scene_name].has(object_id):
		current_changed_record[scene_name][object_id] = {
			"group": group,
			"change": {},
			"action": {}
		}

	current_changed_record[scene_name][object_id]["group"] = group

	var real_data = save[action_or_change]

	for key in real_data.keys():
		current_changed_record[scene_name][object_id][action_or_change][key] = real_data[key]

func load_record():
	var current_scene_name = get_tree().current_scene.name

	if not current_changed_record.has(current_scene_name):
		return

	var scene_saves = current_changed_record[current_scene_name]

	for object_id in scene_saves:
		var object_record = scene_saves[object_id]
		var group = object_record["group"]

		if object_record.has("change"):
			var info = {
				"scene": current_scene_name,
				"object_ID": object_id,
				"group": group,
				"change": object_record["change"]
			}
			process_action_and_change(info, "change")

		if object_record.has("action"):
			var info = {
				"scene": current_scene_name,
				"object_ID": object_id,
				"group": group,
				"action": object_record["action"]
			}
			process_action_and_change(info, "action")
			
			
#加载有schedule的东西
func load_defult_objects_in_current_scene():
	var current_week_period = TimeManager.current_week_period
	var current_day_period = TimeManager.current_day_period
	var current_scene_name = get_tree().current_scene.name
	
	for object_name in default_object_schedule.keys():
		var object_data = default_object_schedule[object_name]
		var object_schedule = object_data.get("schedule",{})
		if object_schedule.is_empty():
			push_error("这个npc没有写schedule：  ",object_name)
			continue
		if not object_schedule.has(current_week_period):
			continue
		if not object_schedule[current_week_period].has(current_day_period):
			continue
		var current_schedule =  object_schedule[current_week_period][current_day_period]
		var object_group = current_schedule.get("group")
		var object_id = current_schedule.get("object_ID")
		var should_change_scene_name = current_schedule.get("scene")
		if should_change_scene_name != current_scene_name:
			continue
		var object = find_things_in_scene_byID(object_group,object_id)
		if object == null:
			push_error("日程目标不存在： ",object_id)
			continue
		process_current_schedule(object,current_schedule)
		write_record(current_schedule,"change")
#{
#								"scene":"Forecourt",
#								"object_ID":"Forecourt_npc_Mike",
#								"group":"NPC",
#								"change":{
#									"visible":true,
#								"position":Vector2(-535.0,1983.0)
#										}
#						
#							}		
		
			
func process_current_schedule(object: Node, current_schedule: Dictionary):
	var change = current_schedule.get("change", {})
	if change.is_empty():
		return
	if change.has("position"):
		var position = Vector2(change["position"][0],change["position"][1])
		object.global_position = position
	if change.has("visible"):
		object.visible = change["visible"]
	if change.has("facing_dir"):
		var face_dir_vector = Vector2(change["facing_dir"][0],change["facing_dir"][1])
		var facing_dir = face_dir_vector
		if object.has_method("apply_facing_dir"):
			object.apply_facing_dir(facing_dir)

func process_action_and_change(action_or_change_information,action_or_change:String):
	var current_scene_name = get_tree().current_scene.name
	var scene_name = action_or_change_information["scene"]
	if scene_name != current_scene_name:
		return
	
	match action_or_change:
		"action":
			var ID = action_or_change_information["object_ID"]
			var group = action_or_change_information["group"]
			var actions = action_or_change_information["action"]

			if group == "NPC":
				for action_name in actions.keys():
					match action_name:
						"following":
							should_follow(ID, group, action_or_change_information)
						

		"change":
			var group = action_or_change_information["group"]
			var object_id = action_or_change_information["object_ID"]
			var change = action_or_change_information["change"]
			var body = find_things_in_scene_byID(group, object_id)
			
			if body == null:
				print("没有找到body")
				return

			if change.has("visible"):
				body.visible = change["visible"]

			if change.has("position"):
				var position = Vector2(change["position"][0],change["position"][1])
				body.global_position = position
			if change.has("facing_dir"):
				var face_dir_vector = Vector2(change["facing_dir"][0],change["facing_dir"][1])
				var facing_dir = face_dir_vector
				if body.has_method("apply_facing_dir"):
					body.apply_facing_dir(facing_dir)
