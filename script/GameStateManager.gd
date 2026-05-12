extends Node

var scene_map = {}

var current_changed_record = {
	"Forecourt":{
					
			},
		
		
	
	"TeachingAreaGF":{}
	
	
					}

var event_state = {
	"开学": {
		"quest_states": {
						"2": [
								{
							"scene": "Forecourt",
							"object_ID": "npc_Forecourt_Mike",
							"group":"NPC",
							"action": {
								
										"following":{
										"enable":true,
										"target_ID":"player",
										"target_group":"player"
												}
									}
								}
					
							]
						
						}
			}
}

var world_state = {
	"开学": {
		"quest_states": {
			"1": [
					{
					"scene": "Forecourt",
					"object_ID":"npc_Forecourt_Mike" ,
					"group": "NPC",
					"change": {
								"visible": true,
								"position":Vector2(-1072.0, 1477.0)
							}
					}	
				
				
					],
					
			
			
		}
	}
}

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
		print(current_changed_record )
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
				body.global_position = change["position"]
