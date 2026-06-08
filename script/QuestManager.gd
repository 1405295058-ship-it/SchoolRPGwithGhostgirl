#QuestManager.gd
extends Node
var quest_data =  {}
var unlocked_quest = []
var active_quest = []
var current_objective = []
var current_tracking_quest = ""
enum quest_progress_status {
	lock,
	unlock,
	active,
	finished
	
}
var quest_progress_data = {
	"开学": 
	{
		"quest_progress_status" : quest_progress_status.active,
		"current_state": 1,
		"objective_progress": {},
		"unlock_quest":"不对劲！"
	},
	"不对劲！": 
	{
		"quest_progress_status" : quest_progress_status.lock,
		"current_state": 1,
		"objective_progress": {},
		"unlock_quest":""
	}
	
	
}
signal quest_hint_should_refresh
signal tracking_quest_changed
#dfihsduifhifhHFijhfjIAHIjhffuoasdfoshdoufhsuodhfuosauodfusahfuasughasudgasdfatrta
#awdhajowehdfjWHAFGWAHEWAJIHIWAgeithwoetw
#jehrjoHROJwhigasijghaweijhgijegtisehuiewuierahuoerqhuoeqhuotehuiheruitgeauteuohg


func _ready() -> void:
	load_Data_from_json()
	update_available_quest()
	quest_hint_should_refresh.emit()
	
	


func update_available_quest():
	
	active_quest.clear()
	unlocked_quest.clear()
	
	for quest in quest_progress_data:
		var quest_progress = quest_progress_data[quest]["quest_progress_status"]
		if quest_progress == quest_progress_status.unlock:
			unlocked_quest.append(quest)
			update_unactive_quest_world()
			quest_hint_should_refresh.emit()
			tracking_quest_changed.emit()
		elif quest_progress == quest_progress_status.active :
			var quest_name = quest
			var quest_state_str = str(quest_progress_data[quest]["current_state"])
			GameStateManager.world_state_update(quest_name,quest_state_str)	
			GameStateManager.event_state_update(quest_name,quest_state_str)	
			active_quest.append(quest)
			quest_hint_should_refresh.emit()
			tracking_quest_changed.emit()
			
			
func load_Data_from_json():
	var data = FileAccess.get_file_as_string("res://QuestResources/QuestData/QuestData.json")
	var parsed_data = JSON.parse_string(data)
	if parsed_data :
		quest_data = parsed_data
	else:
		print("fail to parsed")
		
	

#给npc更新dialoglist
func update_character_dialoglist(npc_dialog_data: Dictionary) -> Array:
	var rules = [
		{"quests":active_quest,"status":"active","type":"main"},
		{"quests":active_quest,"status":"active","type":"sub"},
		{"quests":unlocked_quest,"status":"unlock","type":"main"},
		{"quests":unlocked_quest,"status":"unlock","type":"sub"}
	]
	for rule in rules:
		for quest_name in rule["quests"]:
			if not npc_dialog_data.has(quest_name):
				continue

			if quest_data[quest_name]["type"] != rule["type"]:
				continue

			if rule["status"] == "active":
				if not npc_dialog_data[quest_name].has("quest_states"):
					continue

				var state_str = str(quest_progress_data[quest_name]["current_state"])
				return npc_dialog_data[quest_name]["quest_states"].get(state_str, [])

			if rule["status"] == "unlock":
				return npc_dialog_data[quest_name].get("unlock_dialog", [])

	return []
	
		
func find_objectives_by_quest_name(quest_name):
	if quest_name == "":
		return []

	if not quest_progress_data.has(quest_name):
		return []

	if not quest_data.has(quest_name):
		return []

	if quest_progress_data[quest_name]["quest_progress_status"] != quest_progress_status.active:
		return []

	var quest_state_str = str(quest_progress_data[quest_name]["current_state"])

	if not quest_data[quest_name].has("quest_states"):
		return []

	if not quest_data[quest_name]["quest_states"].has(quest_state_str):
		return []

	return quest_data[quest_name]["quest_states"][quest_state_str].get("objective", [])
func find_quest_discription_by_quest_name(quest_name):
	var quest_state_str
	var quest_discription
	if quest_progress_data .has( quest_name) :
		var quest_state = quest_progress_data [quest_name]["current_state"]
		quest_state_str = str(quest_state)
	if quest_state_str != null :
		quest_discription = quest_data[quest_name]["quest_states"][quest_state_str]["quest_description"]
	else:
		return ""	
	return quest_discription
func add_objective_progress(quest_name:String,objective:Dictionary,amount:int):
	var this_quest_progress = quest_progress_data[quest_name]["objective_progress"]
	var objective_key = objective.get("in_code", "")
	var target_amount = objective.get("target_amount",1)
	if objective_key == "":
		print("你这个任务没有填key")
		return
	if this_quest_progress .has(objective_key):
		var current_amount = this_quest_progress.get(objective_key, 0)
		current_amount += amount
		current_amount = min(current_amount,target_amount)
		this_quest_progress[objective_key] = current_amount
	else:
		this_quest_progress[objective_key] = amount	
	print(this_quest_progress)
	if is_all_objectives_finish(quest_name):
		clear_objective_progress(quest_name)
		update_quest_state(quest_name)
	else:
		quest_hint_should_refresh.emit()
		tracking_quest_changed.emit()
		
		
func clear_objective_progress(quest_name:String):
	quest_progress_data[quest_name]["objective_progress"] = {}
	
func is_all_objectives_finish(quest_name:String):
	var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
	var objectives = quest_data[quest_name]["quest_states"][quest_state_str]["objective"]
	var progress = quest_progress_data[quest_name]["objective_progress"]
	for objective in objectives:
		var in_code_key = objective.get("in_code","")
		var target_amount = objective.get("target_amount",1)
		var current_amount = progress.get(in_code_key, 0)
		if target_amount>current_amount:
			return false
	return true
	
func check_event_is_quest_need(event_name:String,amount:int):
	var quest_state_str = ""

	# 先检查已经 active 的任务目标
	for quest in active_quest:
		if quest_progress_data[quest]["quest_progress_status"] != quest_progress_status.active:
			continue

		var quest_state = quest_progress_data[quest]["current_state"]
		quest_state_str = str(quest_state)

		if not quest_data[quest]["quest_states"].has(quest_state_str):
			continue

		var objectives = quest_data[quest]["quest_states"][quest_state_str].get("objective", [])

		for objective in objectives:
			var objective_event = objective.get("in_code", "")
			if event_name == objective_event:
				add_objective_progress(quest, objective, amount)
				return

	# 再检查 unlocked 任务是否应该被激活
	for quest in unlocked_quest:
		if quest_progress_data[quest]["quest_progress_status"] != quest_progress_status.unlock:
			continue

		var data = quest_data[quest]
		var active_method = data.get("active_method", {})

		if active_method.is_empty():
			continue

		var active_event = active_method.get("active_event", "")

		if event_name == active_event:
			update_quest_state(quest)
			return
		
		
			
func update_quest_state(quest_name):
	print("update_quest_state:", quest_name, " status:", quest_progress_data[quest_name]["quest_progress_status"])
	if quest_progress_data [quest_name]["quest_progress_status"] == quest_progress_status.unlock:#这个是激活任务的
		quest_progress_data [quest_name]["quest_progress_status"] = quest_progress_status.active
		var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
		GameStateManager.world_state_update(quest_name,quest_state_str)	
		GameStateManager.event_state_update(quest_name,quest_state_str)
		
		update_available_quest() 
		quest_hint_should_refresh.emit()
		return
	
	#这后面是如果已经激活了
	quest_progress_data [quest_name]["current_state"] += 1
	var quest_state_str = str(quest_progress_data [quest_name]["current_state"])
	if not quest_data[quest_name]["quest_states"].has(quest_state_str):
		quest_progress_data [quest_name]["quest_progress_status"] = quest_progress_status.finished
		check_if_track_quest_finish(quest_name)
		if quest_progress_data[quest_name]["unlock_quest"] != "":
			var unlock_quest = quest_progress_data [quest_name]["unlock_quest"]
			if quest_data[unlock_quest].has("active_method"):
				quest_progress_data [unlock_quest]["quest_progress_status"] = quest_progress_status.unlock
			else:
				quest_progress_data [unlock_quest]["quest_progress_status"] = quest_progress_status.active
		update_available_quest() 
		return
	
	GameStateManager.world_state_update(quest_name,quest_state_str)	
	GameStateManager.event_state_update(quest_name,quest_state_str)
	quest_hint_should_refresh.emit()	
	tracking_quest_changed.emit()
		
		
func update_unactive_quest_world():
	for quest_name in unlocked_quest:

		var active_method = quest_data[quest_name].get("active_method", {})

		if active_method.is_empty():
			continue

		GameStateManager.world_state_update(
			quest_name,
			"unactive"
		)

		GameStateManager.event_state_update(
			quest_name,
			"unactive"
		)

func get_hint_type_by_object_id(ID:String):
	#active 的 hint优先处理
	for quest_name in active_quest:
		var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
		var objectives = quest_data[quest_name]["quest_states"][quest_state_str]["objective"]
		for objective in objectives:
			if objective.get("target_id", "") == ID:
				return "active"
	#接下来是unlocked
	for quest_name in unlocked_quest:
		var active_method = quest_data[quest_name].get("active_method",{})

		if active_method.is_empty():
			continue

		if active_method.get("target_id", "") == ID:
			return "unlocked"
	return ""

func check_if_track_quest_finish(quest_name:String):
	if quest_name == current_tracking_quest:
		current_tracking_quest = ""

func set_tracking_quest(quest_name: String):
	current_tracking_quest = quest_name
	tracking_quest_changed.emit()
	
