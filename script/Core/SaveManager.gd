extends Node


var save_data:Dictionary

var save_data_slot_path:= {
											"save_data_1":{
												"can_load":false,
												"save_time":"",
												"path":"res://SaveData/SaveData1.json"
											},													
											"save_data_2":{
												"can_load":false,
												"save_time":"",
												"path":"res://SaveData/SaveData2.json"
											},	
											"save_data_3":{
												"can_load":false,
												"save_time":"",
												"path":"res://SaveData/SaveData3.json"
											},	
											"save_data_4":{
												"can_load":false,
												"save_time":"",
												"path":"res://SaveData/SaveData4.json"
											},	
											"save_data_5":{
												"can_load":false,
												"save_time":"",
												"path":"res://SaveData/SaveData5.json"
											}
					}				

func _ready() -> void:
	refresh_slot()
	

func refresh_slot():
	for slot in save_data_slot_path:
		var save_data_path = save_data_slot_path[slot]["path"]
		var save_data_local = read_json_file(save_data_path)
		
		var can_load = save_data_local.get("can_load", false)
		var save_time = save_data_local.get("save_time", "")
		save_data_slot_path[slot]["can_load"] = can_load
		save_data_slot_path[slot]["save_time"] = save_time
		
func can_slot_load(slot_id:String):
	return save_data_slot_path[slot_id]["can_load"]
func get_save_time(slot_id:String)->String:
	return save_data_slot_path[slot_id]["save_time"]	

func start_new_game():
	get_new_game_data()
	call_manager()
	
func load_game(slot_id:String):
	print("开始加载")
	if save_data_slot_path[slot_id]["can_load"]:
		print("可以加载")
		save_data = read_json_file(save_data_slot_path[slot_id]["path"])
		call_manager()
	else:
		print("不可以读取这个的啦啦")
func get_new_game_data():
	save_data = read_json_file("res://SaveData/NewGameData.json")

func call_manager():
	print("开始call manager")
	QuestManager.load_save_data(save_data)
	GameStateManager.load_save_data(save_data)
	TimeManager.load_save_data(save_data)
	DailyRoutineManager.load_save_data(save_data)
	InventoryManager.load_save_data(save_data)
	DialogBox.load_save_data(save_data)
	set_up_scene(save_data)
	
func set_up_scene(save_data:Dictionary):
	print("开始set up cg")
	await FadeLayer.fade_out(3)
	interapt_cg()
	await SceneManager.load_save_data(save_data)
	await FadeLayer.fade_in(3)
	
	NormalStateUi.refresh_after_load()
	
	print("加载场景最后 CG 状态：", NormalStateUi.is_cg_playing)
	
func save_game_to_slot(slot_id:String):
	
	if not save_data_slot_path.has(slot_id):
		push_error("没有此slot_id:", slot_id)
		return
	
	var current_save_data = {
		"can_load" : true,
		"save_time":Time.get_datetime_string_from_system(false, true),
		"quest_manager" : QuestManager.get_save_data(),
		"gamestate_manager" : GameStateManager.get_save_data(),
		"time_manager" : TimeManager.get_save_data(),
		"daily_routine_manager": DailyRoutineManager.get_save_data(),
		"inventory_manager": InventoryManager.get_save_data(),
		"scene_manager": SceneManager.get_save_data(),
		"dialog_box": DialogBox.get_save_data()
	}
	
	
	var success := write_json_file(
		save_data_slot_path[slot_id]["path"],
		current_save_data
	)

	if success:
		save_data = current_save_data

	refresh_slot()
	
	return success
	
func get_latest_slot_name()->String:
	var latest_slot_time = ""
	var latest_slot = ""
	for slot in save_data_slot_path:
		var save_time = save_data_slot_path[slot]["save_time"]
		if save_time.is_empty():
			continue
		if latest_slot.is_empty():
			latest_slot = save_time
		if save_time > latest_slot_time:
			latest_slot_time = save_time
			latest_slot = slot
	return latest_slot
func read_json_file(file_path: String) -> Dictionary:
	# 1. 检查文件是否存在。
	if not FileAccess.file_exists(file_path):
		push_error("文件不存在：" + file_path)
		return {}

	# 2. 以只读方式打开文件。
	var file := FileAccess.open(file_path, FileAccess.READ)

	if file == null:
		push_error(
			"无法打开文件：%s，错误码：%s"
			% [file_path, FileAccess.get_open_error()]
		)
		return {}

	# 3. 读取整个文件的文字。
	var text := file.get_as_text()

	# 4. 读取完毕，关闭文件。
	file.close()

	# 5. 把 JSON 文字解析成数据。
	var json := JSON.new()
	var error := json.parse(text)

	if error != OK:
		push_error(
			"JSON 解析失败，第 %d 行：%s"
			% [json.get_error_line(), json.get_error_message()]
		)
		return {}

	# 6. 检查最外层是不是字典。
	if not json.data is Dictionary:
		push_error("JSON 最外层必须是字典：" + file_path)
		return {}

	# 7. 返回解析后的字典。
	return json.data

func write_json_file(file_path: String, data: Dictionary) -> bool:
	# 1. 打开文件；不存在就创建。
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		push_error(
			"无法创建或打开文件：%s，错误码：%s"
			% [file_path, FileAccess.get_open_error()]
		)
		return false

	# 2. 把字典转换成 JSON 文字。
	# "\t" 用来缩进，让文件里的内容更容易阅读。
	var json_text := JSON.stringify(data, "\t")

	# 3. 写入并刷新缓冲区。
	file.store_string(json_text)
	file.flush()

	var error := file.get_error()
	file.close()

	if error != OK:
		push_error("写入失败，错误码：%s" % error)
		return false

	return true


func interapt_cg():
	if get_tree().current_scene.scene_id == "MainMenu":
		var cg_director = SceneManager.get_cg_director_in_current_scene()
		cg_director.interrupt_cg("Start_Animation")


	
