#QuestManager.gd
extends Node
var quest_data =  {}
var available_quest = []
var current_objective = []
var quest_progress = {
	"开学": 
	{
		"unlocked": true,
		"finished": false,
		"current_state": 1,
		"unlock_quest":""
	}
	
	
}
#dfihsduifhifhHFijhfjIAHIjhffuoasdfoshdoufhsuodhfuosauodfusahfuasughasudgasdfatrta
#awdhajowehdfjWHAFGWAHEWAJIHIWAgeithwoetw
#jehrjoHROJwhigasijghaweijhgijegtisehuiewuierahuoerqhuoeqhuotehuiheruitgeauteuohg


func _ready() -> void:
	
	update_available_quest()
	load_Data_from_json()
	print(available_quest)	
	


func update_available_quest():
	available_quest.clear()
	for i in quest_progress:
		var unlocked = quest_progress[i]["unlocked"]
		var finished = quest_progress[i]["finished"]
		if unlocked == true and finished == false :
			available_quest.append(i)
func load_Data_from_json():
	var data = FileAccess.get_file_as_string("res://QuestResources/QuestData/QuestData.json")
	var parsed_data = JSON.parse_string(data)
	if parsed_data :
		quest_data = parsed_data
	else:
		print("fail to parsed")
		
		

#给npc更新dialoglist
func update_character_dialoglist(npc_dialog_data):
	if available_quest.is_empty():
		return []
	
	# 先检查主线
	for quest_name in available_quest:
		if not npc_dialog_data.has(quest_name):
			continue
		
		if quest_data[quest_name]["type"] == "main":
			var quest_state_index = quest_progress[quest_name]["current_state"]
			var quest_index_string = str(quest_state_index)
			
			return npc_dialog_data[quest_name]["quest_states"].get(quest_index_string, [])
	# 再检查支线
	for quest_name in available_quest:
		if not npc_dialog_data.has(quest_name):
			continue
		if quest_data[quest_name]["type"] == "sub":
			var quest_state_index = quest_progress[quest_name]["current_state"]
			var quest_index_string = str(quest_state_index)
			return npc_dialog_data[quest_name]["quest_states"].get(quest_index_string, [])
	
	return []
func find_objectives_by_quest_name(quest_name):
	var quest_state_str
	var quest_objectives = []
	if quest_progress.has( quest_name) :
		var quest_state = quest_progress[quest_name]["current_state"]
		quest_state_str = str(quest_state)
	if quest_state_str != null :
		quest_objectives  = quest_data[quest_name]["quest_states"][quest_state_str]["objective"]
	else:
		return[]
	return quest_objectives
func find_quest_discription_by_quest_name(quest_name):
	var quest_state_str
	var quest_discription
	if quest_progress.has( quest_name) :
		var quest_state = quest_progress[quest_name]["current_state"]
		quest_state_str = str(quest_state)
	if quest_state_str != null :
		quest_discription = quest_data[quest_name]["quest_states"][quest_state_str]["quest_description"]
	else:
		return ""	
	return quest_discription

func check_event_is_quest_need(event_name):
	var quest_state_str  = ""
	for quest in available_quest:
		var quest_state = quest_progress[quest]["current_state"]
		quest_state_str = str(quest_state)
		var objectives = quest_data[quest]["quest_states"][quest_state_str]["objective"]
		for i in objectives:
			var objective = i["in_code"]
			if event_name == objective:
				update_quest_state(quest)
				return
		
		
			
func update_quest_state(quest_name):
	quest_progress[quest_name]["current_state"] += 1
	var quest_state_str = str(quest_progress[quest_name]["current_state"])
	
	if not quest_data[quest_name]["quest_states"].has(quest_state_str):
		quest_progress[quest_name]["finished"] = true
		
		if quest_progress[quest_name]["unlock_quest"] != "":
			var unlock_quest = quest_progress[quest_name]["unlock_quest"]
			quest_progress[unlock_quest]["unlocked"] = true
		update_available_quest()
		return
	GameStateManager.world_state_update(quest_name,quest_state_str)	
	GameStateManager.event_state_update(quest_name,quest_state_str)	 
