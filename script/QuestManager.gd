#QuestManager.gd
extends Node
var quest_data:Dictionary =  {}
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

#dfihsduifhifhHFijhfjIAHIjhffuoasdfoshdoufhsuodhfuosauodfusahfuasughasudgasdfatrta
#awdhajowehdfjWHAFGWAHEWAJIHIWAgeithwoetw
#jehrjoHROJwhigasijghaweijhgijegtisehuiewuierahuoerqhuoeqhuotehuiheruitgeauteuohg


func _ready() -> void:
	load_Data_from_json()
	update_quest_list()
	EventBus.time_context_changed.connect(_on_time_context_changed)
	EventBus.set_tracking_quest.connect(set_tracking_quest)
	EventBus.quest_hint_should_refresh.emit()
	
func apply_after_quest_finish(quest_name:String):
	update_quest_list() 
	EventBus.quest_state_changed.emit(quest_name)
	EventBus.a_quest_finished.emit(quest_name)
	EventBus.quest_hint_should_refresh.emit()
	EventBus.tracking_quest_changed.emit()
	
func ending_a_quest_state(quest_name:String,quest_state_str:String):
	update_quest_list() 
	EventBus.quest_state_changed.emit(quest_name)
	EventBus.a_quest_state_finished.emit(quest_name,quest_state_str)
	EventBus.quest_hint_should_refresh.emit()
	EventBus.tracking_quest_changed.emit()
	
	


#================================================================================================================================================================
#QuestManager
#================================================================================================================================================================
	
func load_Data_from_json():
	var data = FileAccess.get_file_as_string("res://QuestResources/QuestData/QuestData.json")
	var parsed_data = JSON.parse_string(data)
	if parsed_data :
		quest_data = parsed_data
	else:
		print("fail to parsed")

func update_quest_list():
	
	
	active_quest.clear()
	unlocked_quest.clear()
	
	for quest in quest_progress_data:
		var quest_progress = quest_progress_data[quest]["quest_progress_status"]
		if quest_progress == quest_progress_status.unlock:
			unlocked_quest.append(quest)
			
		elif quest_progress == quest_progress_status.active :
			active_quest.append(quest)
			
	update_unactive_quest_world()				
func check_event_is_quest_need(event_name:String,amount:int):
	var quest_state_str = ""

	# 先检查已经 active 的任务目标
	for quest_name in active_quest:
		if quest_progress_data[quest_name]["quest_progress_status"] != quest_progress_status.active:
			continue

		var quest_state = quest_progress_data[quest_name]["current_state"]
		quest_state_str = str(quest_state)

		if not quest_data[quest_name]["quest_states"].has(quest_state_str):
			continue

		var objectives = quest_data[quest_name]["quest_states"][quest_state_str].get("objective", [])

		for objective in objectives:
			var objective_event = objective.get("in_code", "")
			if event_name == objective_event:
				if not can_progress_objective(quest_name,objective):
					EventBus.quest_hint_should_refresh.emit()
					EventBus.tracking_quest_changed.emit()
					return
				add_objective_progress(quest_name, objective, amount)
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
			if active_method.has("time_condition"):
				if not TimeManager.is_time_match(active_method["time_condition"]):
					EventBus.quest_hint_should_refresh.emit()
					EventBus.tracking_quest_changed.emit()
					return
			update_quest_state(quest)
			return		

func update_quest_state(quest_name):
	print("update_quest_state:", quest_name, " status:", quest_progress_data[quest_name]["quest_progress_status"])
	#这个是激活任务的
	var quest_state_str = ""
	if quest_progress_data [quest_name]["quest_progress_status"] == quest_progress_status.unlock:
		quest_progress_data [quest_name]["quest_progress_status"] = quest_progress_status.active
		quest_state_str = str(quest_progress_data[quest_name]["current_state"])
		print("激活任务: ",quest_name)
		ending_a_quest_state(quest_name,quest_state_str)
		return
	
	#这后面是如果已经激活了
	quest_progress_data [quest_name]["current_state"] += 1
	quest_state_str = str(quest_progress_data [quest_name]["current_state"])
	if not quest_data[quest_name]["quest_states"].has(quest_state_str):
		quest_progress_data [quest_name]["quest_progress_status"] = quest_progress_status.finished
		check_if_track_quest_finish(quest_name)
		if quest_progress_data[quest_name]["unlock_quest"] != "":
			var unlock_quest = quest_progress_data [quest_name]["unlock_quest"]
			if quest_data[unlock_quest].has("active_method"):
				quest_progress_data [unlock_quest]["quest_progress_status"] = quest_progress_status.unlock
			else:
				quest_progress_data [unlock_quest]["quest_progress_status"] = quest_progress_status.active
		#这里是结束任务
		await FadeLayer.fade_out(0.5)
		apply_after_quest_finish(quest_name)
		await FadeLayer.fade_in(0.5)
		return
	ending_a_quest_state(quest_name,quest_state_str)

func set_tracking_quest(quest_name: String):
	current_tracking_quest = quest_name
	EventBus.tracking_quest_changed.emit()
	
func check_if_track_quest_finish(quest_name:String):
	if quest_name == current_tracking_quest:
		current_tracking_quest = ""

	
func _on_time_context_changed(current_week_period:String,current_day_period:String):
	EventBus.quest_hint_should_refresh.emit()
	EventBus.tracking_quest_changed.emit()
	
	
#================================================================================================================================================================
#QuestManager
#================================================================================================================================================================	


#================================================================================================================================================================
#QuestProgressStore
#================================================================================================================================================================	
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
		EventBus.quest_hint_should_refresh.emit()
		EventBus.tracking_quest_changed.emit()
		
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


		


		
		
			

#================================================================================================================================================================
#QuestProgressStore
#================================================================================================================================================================
#================================================================================================================================================================
#QuestConditionChecker
#================================================================================================================================================================	

func is_npc_related_objective_time_available(quest_name:String,npc_id:String)-> bool:
	
	var quest_status = quest_progress_data[quest_name]["quest_progress_status"]
	
	
	match quest_status:
		quest_progress_status.active:
			var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
			var state_data = quest_data[quest_name]["quest_states"].get(quest_state_str,{})
			var objectives = state_data.get("objective",[])
			for objective in objectives:
				if objective.get("target_id","")!= npc_id:
					continue
				if not is_objective_time_available(objective):
					return false
				
			return true
		quest_progress_status.unlock:
			var active_method = quest_data[quest_name].get("active_method",{})
			if active_method.get("target_id","")!= npc_id:
					return true
			if not is_objective_time_available(active_method):
					return false
			return true
			
	
	return true		


func is_objective_time_available(objective:Dictionary)->bool:
	if not objective.has("time_condition"):
		return true
	
	return TimeManager.is_time_match(objective["time_condition"])

func is_quest_time_condition_available(quest_name:String)->bool:
	var quest_state_str = str(quest_progress_data[quest_name]["current_state"])
	var state_data = quest_data[quest_name]["quest_states"].get(quest_state_str,{})
	
	if not state_data.has("time_condition"):
		return true
	
	return TimeManager.is_time_match(state_data["time_condition"])
		

func can_progress_objective(quest_name:String,objective:Dictionary):
	if not is_quest_time_condition_available(quest_name):
		return false
	if not is_objective_time_available(objective):
		return false
	return true


		
		

#================================================================================================================================================================
#QuestConditionChecker
#================================================================================================================================================================


#================================================================================================================================================================
#QuestDialogResolver
#================================================================================================================================================================		

#给npc更新dialoglist
func resolve_character_dialoglist(npc_dialog_data: Dictionary,npc_id:String) -> Dictionary:
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
				
				if not is_npc_related_objective_time_available(quest_name,npc_id):
					start_talk_state = "time_no_right"
				var state_str = str(quest_progress_data[quest_name]["current_state"])
				return {
					"dialog_list": npc_dialog_data[quest_name]["quest_states"].get(state_str, []),
					"start_talk_state":start_talk_state
				}
			
			if rule["status"] == "unlock":#解锁状态#active检查完正常就return了 如果到了这里说明没有active的任务
				if not is_npc_related_objective_time_available(quest_name,npc_id):
					continue
				return {
					"dialog_list": npc_dialog_data[quest_name].get("unlock_dialog", []),
					"start_talk_state":start_talk_state
				}

	return {
		"dialog_list":[],
		"start_talk_state":start_talk_state
	}


func find_talk_state(dialog_list:Array,talk_state:String)->Dictionary:
	for state in dialog_list:
		if state.get("talk_state","")== talk_state:
			return state
	return {}		

#================================================================================================================================================================
#QuestDialogResolver
#================================================================================================================================================================

#================================================================================================================================================================
#QuestHintResolver
#================================================================================================================================================================
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
			if is_objective_time_available(active_method):
				return "unlocked"
			return ""
	return ""	


#================================================================================================================================================================
#QuestHintResolver
#================================================================================================================================================================				


	


func update_unactive_quest_world():
	for quest_name in unlocked_quest:

		var active_method = quest_data[quest_name].get("active_method", {})

		if active_method.is_empty():
			continue
		
		EventBus.unlocked_quest_world_should_apply.emit(quest_name)
	



	
