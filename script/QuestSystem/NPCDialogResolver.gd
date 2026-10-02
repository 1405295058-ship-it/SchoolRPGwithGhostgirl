extends RefCounted
class_name NPCDialogResolver


static func resolve_character_dialoglist(npc_dialog_data: Dictionary,npc_id:String) -> Dictionary:
	var active_quest = QuestManager.get_active_quest()
	var unlocked_quest = QuestManager.get_unlocked_quest()
	var quest_data = QuestManager.get_quest_data()
	var quest_progress_data = QuestManager.get_quest_progress_data()
	var rules = [
		{"quests":active_quest,"status":"active","type":"main"},
		{"quests":active_quest,"status":"active","type":"sub"},
		{"quests":unlocked_quest,"status":"unlock","type":"main"},
		{"quests":unlocked_quest,"status":"unlock","type":"sub"}
	]
	var start_talk_state = "start"
	for rule in rules:
		
		for quest_name in rule["quests"]:
			
			if not npc_dialog_data.has(quest_name):
				continue

			if quest_data[quest_name]["type"] != rule["type"]:#找到符合type的任务
				continue
			
			
			
			if rule["status"] == "active":#激活状态
				if not npc_dialog_data[quest_name].has("quest_states"):#如果这个阶段npc不需要说话的话
					continue
				#这里开始就是npc需要说话的时候了
				
				if not QuestManager.is_npc_related_objective_time_available(quest_name,npc_id):
					start_talk_state = "time_no_right"
				var state_str = str(quest_progress_data[quest_name]["current_state"])
				return {
					"dialog_list": npc_dialog_data[quest_name]["quest_states"].get(state_str, []),
					"start_talk_state":start_talk_state
				}
			
			if rule["status"] == "unlock":#解锁状态#active检查完正常就return了 如果到了这里说明没有active的任务
				if not QuestManager.is_npc_related_objective_time_available(quest_name,npc_id):
					continue
				return {
					"dialog_list": npc_dialog_data[quest_name].get("unlock_dialog", []),
					"start_talk_state":start_talk_state
				}

	return {
		"dialog_list":[],
		"start_talk_state":start_talk_state
	}
