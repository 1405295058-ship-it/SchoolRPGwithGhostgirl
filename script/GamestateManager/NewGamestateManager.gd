#重构后的gamestatemanager
extends Node



const WORLD_STATE_PATH:="res://QuestResources/WorldStateControl/WorldStateFile.json"
const EVENT_STATE_PATH:="res://QuestResources/WorldStateControl/EventStateFile.json"
const DEFAULT_OBJECT_SCHEDULE_PATH:="res://QuestResources/WorldStateControl/DefaultObjectScheduleFile.json"

var cg_played_once = {}
#要移动

var current_changed_record:Dictionary 

#"morning",
#	"lunch_time",
#	"dinner_time",
#	"night_time"
var default_object_schedule := {}
var event_state := {}
var world_state := {}

#初始化模块
var schedule_resolver = ScheduleResolver.new()
var quest_world_resolver = QuestWorldResolver.new()
var record_operator = RecordOperator.new()

func _ready() -> void:
	default_object_schedule  = read_json_file(DEFAULT_OBJECT_SCHEDULE_PATH)
	event_state = read_json_file(EVENT_STATE_PATH)
	world_state = read_json_file(WORLD_STATE_PATH)
	
	EventBus.a_quest_state_finished.connect(on_new_quest_state_entered)

#======================================================================================

func on_new_quest_state_entered(quest_name, quest_state):
	var scene_id = get_tree().current_scene.scene_id
	var quest_world_change = quest_world_resolver.on_quest_stage_entered(quest_name, quest_state)
	
	record_operator.write_record(quest_world_change)
	
	var record_changes = record_operator.resolve_record(scene_id, TimeManager.week_period, TimeManager.day_period)
	
	
#======================================================================================

func set_up_scene():
	refresh_scene_state()
	
func set_up_modules():
	schedule_resolver.set_up_resolver(default_object_schedule)
	quest_world_resolver.set_up_resolver(world_state, event_state)
	record_operator.set_up_operator(default_object_schedule)

func refresh_scene_state():
	var scene_id = get_tree().current_scene.scene_id
	var schedule_changes = schedule_resolver.resolve_schedule(scene_id, TimeManager.week_period, TimeManager.day_period)
	
	
func load_save_data(save_data):
	var gamestate_manager_data = save_data["gamestate_manager"]
	
	current_changed_record = gamestate_manager_data.get("current_changed_record",{})
	cg_played_once = gamestate_manager_data.get("cg_played_once",{})
	
func get_save_data()-> Dictionary:
	return {
		"current_changed_record": current_changed_record.duplicate(true),
		"cg_played_once": cg_played_once.duplicate(true)
	}	

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
