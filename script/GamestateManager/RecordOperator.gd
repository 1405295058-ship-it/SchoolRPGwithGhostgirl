extends RefCounted
class_name RecordOperator

var current_changed_record : ={
	"Forecourt":{},
												
	"TeachingAreaGF":{},
											
	"BoyAccommodationGF":{},
											
	"CenterCampus":{}
}

var actions_to_execute := []

var completed_action := []


func set_up_operator(record:Dictionary):
	current_changed_record = record


func resolve_record(scene_id:String, day_period:String, week_period:String)->Array:
	var current_scene_record = current_changed_record.get(scene_id,{})
	var record_changes:Array = []
	
	if current_scene_record.is_empty():
		push_error("此scene不存在", scene_id)
		return []
	
	for key in current_changed_record[scene_id]:
		var object_changes = current_scene_record[key].get("entries",[])
		var object_group = current_scene_record[key].get("group","")
		
		for change in object_changes:
			if change.has("time_condition"):
				if not is_time_available(change, day_period, week_period):
					continue
			
			record_changes.append(
				{
					"object_ID": key,
					"group": object_group,
					"change": change["change"].duplicate(true)
				}
			)
	return record_changes	
		
			
func is_time_available(change:Dictionary, day_period:String, week_period:String)->bool:			
	var day_period_required:Array = change["time_condition"].get("day_period",[day_period])
	var week_period_required:Array= change["time_condition"].get("week_period",[week_period])
	if not day_period_required.has(day_period) or not week_period_required.has(week_period):
		return false		
		
	return true		
#仅仅写入world_change
func write_record(quest_world_changes: Dictionary) -> void:
	var world_changes: Array = quest_world_changes.get("world_change", [])
	
	for change in world_changes:
		var effective_scenes: Array = change["scene"]
		var object_id: String = change["object_ID"]

		for scene_id in effective_scenes:
			# 1. 检查场景是否存在
			if not current_changed_record.has(scene_id):
				push_error("此场景不存在 检查是否登记或者是拼写错误",scene_id)
				continue
				
			# 2. 第一次记录这个对象，创建对象记录。
			if not current_changed_record[scene_id].has(object_id):
				current_changed_record[scene_id][object_id] = {
					"group": change["group"],
					"entries": []
				}

			# 3. 向这个对象追加一条修改，保留自己的时间条件。
			var entries: Array = (
				current_changed_record[scene_id][object_id]["entries"]
			)

			entries.append({
				"time_condition": change.get("time_condition", {}).duplicate(true),
				"change": change["change"].duplicate(true)
			})
#注册action
func register_event(quest_world_changes:Dictionary):
	var event_changes: Array = quest_world_changes.get("event_change", [])
	
	for event in event_changes:
		actions_to_execute.append(event.duplicate(true))
		
func register_to_complete_action(action: Dictionary) -> void:
	# 重复收到完成通知，不重复登记。
	if is_action_completed(action):
		return

	if not actions_to_execute.has(action):
		push_error("完成的 action 未登记在 actions_to_execute 中")
		return

	actions_to_execute.erase(action)
	completed_action.append(action.duplicate(true))
	
		
func is_action_completed(action:Dictionary)->bool:
	return completed_action.has(action)
	

	
# Json 结构 
# scene_id -> {object_id:change,   object_id:change }	change-> group , entries-> time_condition, change

#time_condition -> {
#						"week_period": ["monday"],
#						"day_period": ["lunch_time"]
#					}
#{
#	"Forecourt": {
#		"npc_Mike": {
#			"group": "NPC",
#			"entries": [
#				{
#					"time_condition": {},
#					"change": {
#						"following": {
#							"enable": true,
#							"target_ID": "player",
#							"target_group": "player"
#						}
#					}
#				}
#			]
#		},
#
#		"npc_Evelyn": {
#			"group": "NPC",
#			"entries": [
#				{
#					"time_condition": {
#						"week_period": ["monday"],
#						"day_period": ["lunch_time"]
#					},
#					"change": {
#						"visible": true,
#						"position": [1319.0, -1105.0],
#						"facing_dir": [0, 1]
#					}
#				}
#			]
#		}
#	},
#
#	"TeachingAreaGF": {
#		"npc_Mike": {
#			"group": "NPC",
#			"entries": [
#				{
#					"time_condition": {},
#					"change": {
#						"following": {
#							"enable": true,
#							"target_ID": "player",
#							"target_group": "player"
#						}
#					}
#				}
#			]
#		}
#	}
#}
