extends Node


var save_data:Dictionary





func start_new_game():
	get_new_game_data()
	call_manager()
	
func load_game():
	save_data = read_json_file("res://SaveData/SaveData.json")
	call_manager()

func get_new_game_data():
	save_data = read_json_file("res://SaveData/NewGameData.json")

func call_manager():
	QuestManager.load_save_data(save_data)
	GameStateManager.load_save_data(save_data)
	TimeManager.load_save_data(save_data)
	DailyRoutineManager.load_save_data(save_data)
	InventoryManager.load_save_data(save_data)
	DialogBox.load_save_data(save_data)
	set_up_scene(save_data)
	
func set_up_scene(save_data:Dictionary):
	await FadeLayer.fade_out(3)
	interapt_cg()
	await SceneManager.load_save_data(save_data)
	await FadeLayer.fade_in(3)
	
	NormalStateUi.refresh_after_load()
	
	print("加载场景最后 CG 状态：", NormalStateUi.is_cg_playing)
func save_game():
	var current_save_data = {
		"quest_manager" : QuestManager.get_save_data(),
		"gamestate_manager" : GameStateManager.get_save_data(),
		"time_manager" : TimeManager.get_save_data(),
		"daily_routine_manager": DailyRoutineManager.get_save_data(),
		"inventory_manager": InventoryManager.get_save_data(),
		"scene_manager": SceneManager.get_save_data(),
		"dialog_box": DialogBox.get_save_data()
	}
	var success := write_json_file(
		"res://SaveData/SaveData.json",
		current_save_data
	)

	if success:
		save_data = current_save_data

	return success
	
	

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
	var cg_director = SceneManager.get_cg_director_in_current_scene()
	
	cg_director.interrupt_cg("Start_Animation")
