extends NPCBase
class_name BasicImportantNPC


var visual_origin_y: float = 0.0

var NPC_name: String = ""
var ID: String = ""
var dialog_json_path: String = ""
var default_dialog: Array = []

var dialog_data: Dictionary = {}
var dialog_result: Dictionary = {}

var initial_state = &"idle"

@export var npc_data: NPCData


func _ready() -> void:
	read_npc_data_resource()

	if npc_data == null:
		return

	animated_sprite.sprite_frames = npc_data.sprite_frame

	super._ready()

	load_from_json()
	resolve_dialog()

	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)

	if not EventBus.quest_hint_should_refresh.is_connected(
		refresh_quest_hint
	):
		EventBus.quest_hint_should_refresh.connect(
			refresh_quest_hint
		)
	
	call_deferred("change_npc_state", initial_state)

func read_npc_data_resource() -> void:
	if npc_data == null:
		push_error("%s 没有设置 NPCData Resource" % name)
		return

	NPC_name = npc_data.NPC_name
	ID = npc_data.ID
	dialog_json_path = npc_data.dialog_json_path
	default_dialog = npc_data.default_dialog


func interact(_player: Node) -> void:
	resolve_dialog()

	if dialog_result.is_empty():
		push_error("%s 的 dialog_result 为空" % ID)
		return

	DialogBox.start_dialog(
		dialog_result.get("dialog_list", []),
		default_dialog,
		dialog_result.get("start_talk_state", "")
	)

	var event_name := "talked_with_" + ID
	QuestManager.check_event_is_quest_need(event_name, 1)


func resolve_dialog() -> void:
	dialog_result = QuestManager.resolve_character_dialoglist(
		dialog_data,
		ID
	)


func load_from_json() -> void:
	if dialog_json_path.is_empty():
		return

	if not FileAccess.file_exists(dialog_json_path):
		push_error(
			"%s 的对话文件不存在：%s"
			% [ID, dialog_json_path]
		)
		return

	var json_text := FileAccess.get_file_as_string(
		dialog_json_path
	)

	var parsed_data = JSON.parse_string(json_text)

	if parsed_data == null:
		push_error("%s 的对话 JSON 解析失败" % ID)
		return

	if not parsed_data is Dictionary:
		push_error("%s 的对话 JSON 根节点必须是 Dictionary" % ID)
		return

	dialog_data = parsed_data


func refresh_quest_hint() -> void:
	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)
