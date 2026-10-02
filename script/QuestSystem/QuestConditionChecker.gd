extends RefCounted
class_name QuestConditionChecker

static func is_objective_time_available(objective:Dictionary)->bool:
	if not objective.has("time_condition"):
		return true
	
	return TimeManager.is_time_match(objective["time_condition"])


static func is_quest_time_condition_available(
quest_name:String, 
quest_progress_data:Dictionary,
quest_data:Dictionary
)->bool:
	var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
	var state_data = quest_data[quest_name]["quest_states"].get(quest_state_str,{})
	
	if not state_data.has("time_condition"):
		return true
	
	return TimeManager.is_time_match(state_data["time_condition"])
		
static func can_progress_objective(
quest_name:String,
objective:Dictionary,
quest_progress_data:Dictionary,
quest_data:Dictionary
):
	if not is_quest_time_condition_available(quest_name,quest_progress_data,quest_data):
		return false
	if not QuestConditionChecker.is_objective_time_available(objective):
		return false
	return true
