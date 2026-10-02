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
	#清空两种questlist 
	active_quest.clear()
	unlocked_quest.clear()
	
	#更具进度data 将任务名字加入questlist
	for quest in quest_progress_data:
		var quest_progress = quest_progress_data[quest]["quest_progress_status"]
		if quest_progress == quest_progress_status.unlock:
			unlocked_quest.append(quest)
			
		elif quest_progress == quest_progress_status.active :
			active_quest.append(quest)
			
	update_unactive_quest_world()
	
#单独加的一个函数 搞忘是干嘛的了	
func update_unactive_quest_world():
	for quest_name in unlocked_quest:

		var active_method = quest_data[quest_name].get("active_method", {})

		if active_method.is_empty():
			continue
		
		EventBus.unlocked_quest_world_should_apply.emit(quest_name)	
		
#判断这个event是否需要
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
		#得到每一個目標
		
		#判断目标是否达成
		for objective in objectives:
			var objective_event = objective.get("in_code", "")
			if event_name == objective_event:
				if not can_progress_objective(quest_name,objective):
					EventBus.quest_hint_should_refresh.emit()
					EventBus.tracking_quest_changed.emit()
					return
				#达成后为objective添加进度
				QuestProgressStore.add_objective_progress(quest_name, objective, amount, quest_progress_data, quest_data)
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



#有保护的找quest discription 是userui专用	
func find_quest_description_by_quest_name(quest_name):
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

func find_objectives_by_quest_name(quest_name):
	return QuestProgressStore.find_objectives_by_quest_name(quest_name,quest_progress_data,quest_data)
		


		
		
			

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
				if not QuestConditionChecker.is_objective_time_available(objective):
					return false
				
			return true
		quest_progress_status.unlock:
			var active_method = quest_data[quest_name].get("active_method",{})
			if active_method.get("target_id","")!= npc_id:
					return true
			if not QuestConditionChecker.is_objective_time_available(active_method):
					return false
			return true
	
	return true		

func is_quest_time_condition_available(quest_name:String)->bool:
	return QuestConditionChecker.is_quest_time_condition_available(quest_name, quest_data, quest_progress_data)

func can_progress_objective(quest_name:String,objective:Dictionary):
	return QuestConditionChecker.can_progress_objective(quest_name,objective,quest_progress_data,quest_data)

#================================================================================================================================================================
#QuestConditionChecker
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
			if QuestConditionChecker.is_objective_time_available(active_method):
				return "unlocked"
			return ""
	return ""	


#================================================================================================================================================================
#QuestHintResolver
#================================================================================================================================================================				

	
#================================================================================================================================================================
#OnlyReadAPI
#================================================================================================================================================================				

func get_quest_data():
	return quest_data
func get_quest_progress_data():
	return quest_progress_data
func get_active_quest():
	return active_quest
func get_unlocked_quest():
	return unlocked_quest
	
