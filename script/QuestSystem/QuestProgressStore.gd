extends RefCounted
class_name QuestProgressStore


static func add_objective_progress(
quest_name:String,
objective:Dictionary,
amount:int,
quest_progress_data:Dictionary,
quest_data:Dictionary
):
	
	var this_quest_progress = quest_progress_data[quest_name]["objective_progress"]
	
	#任务data的key
	var objective_key = objective.get("in_code", "")
	var target_amount = objective.get("target_amount",1)
	
	if objective_key == "":
		print("你这个任务没有填key")
		return
		
	if this_quest_progress .has(objective_key):#如果已经存在 就加target
		var current_amount = this_quest_progress.get(objective_key, 0)
		current_amount += amount
		current_amount = min(current_amount,target_amount)
		this_quest_progress[objective_key] = current_amount
	else:#不存在就创造新的key 对应target amount
		this_quest_progress[objective_key] = amount	
	
	#如果全部完成了 就清除progress 让questmanager更新任务阶段
	if is_all_objectives_finish(quest_name,quest_progress_data,quest_data):
		clear_objective_progress(quest_name,quest_progress_data)
		QuestManager.update_quest_state(quest_name)
	#如果没有 通知UI系统更新
	else:
		EventBus.quest_hint_should_refresh.emit()
		EventBus.tracking_quest_changed.emit()

#清除此任务的objective完成记录		
static func clear_objective_progress(
quest_name:String,
quest_progress_data:Dictionary
):
	
	quest_progress_data[quest_name]["objective_progress"] = {}

#判断是否全部做完	

static func is_all_objectives_finish(
	quest_name:String,
	quest_progress_data:Dictionary,
	quest_data:Dictionary
	)->bool:
	
	var objectives = find_objectives_by_quest_name(quest_name,quest_progress_data,quest_data)
	var progress = quest_progress_data[quest_name]["objective_progress"]
	#通过现在的state 分别找到data里应该完成的目标 和 progress里面的真实任务进度
	
	#data里面的每一个任务
	for objective in objectives:
		var in_code_key = objective.get("in_code","")
		#任务代号
		var target_amount = objective.get("target_amount",1)
		#应该达到的量
		var current_amount = progress.get(in_code_key, 0)
		#现在的真实量
		if target_amount>current_amount:
			return false
	return true
	
	#有保护的找objectives 经常搞忘用
static func find_objectives_by_quest_name(
quest_name:String,
quest_progress_data:Dictionary,
quest_data:Dictionary
)->Array:
	if quest_name == "":
		return []

	if not quest_progress_data.has(quest_name):
		return []

	if not quest_data.has(quest_name):
		return []


	var quest_state_str = str(quest_progress_data[quest_name]["current_state"])

	if not quest_data[quest_name].has("quest_states"):
		return []

	if not quest_data[quest_name]["quest_states"].has(quest_state_str):
		return []

	return quest_data[quest_name]["quest_states"][quest_state_str].get("objective", [])
