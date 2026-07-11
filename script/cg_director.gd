#CGDirector
extends Node2D

@export var ID := "CGDirector"
@export_file("*.json") var cg_dialog_database_path = ""

var cg_dialog_database = {}

@onready var animation_player := $AnimationPlayer
var played_once = {}



func _ready() -> void:
	cg_dialog_database = load_file_from_json(cg_dialog_database_path)
	EventBus.play_this_animation.connect(play_animation)
	
	
func play_animation(anim_name):
	if played_once and played_once.get(anim_name, false):
		return
	if animation_player.is_playing():
		return


	played_once[anim_name] = true
	animation_player.play(anim_name)
	EventBus.start_play_cg.emit()
	
	await animation_player.animation_finished
	EventBus.end_play_cg.emit()



func start_cg_dialog(cg_dialog_name:String):
	if not cg_dialog_database.has(cg_dialog_name):
		push_error("缺少这一段的cg_dialog: ", cg_dialog_name)
		return
	var cg_dialog = cg_dialog_database.get(cg_dialog_name,[])
	animation_player.pause()
	
	DialogBox.start_dialog([],cg_dialog)
	await EventBus.on_dialog_finished
	
	animation_player.play()
	
	
func load_file_from_json(path:String)->Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON不存在： ",path)
		return {}
	
	var text = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Json解析失败或者不是JSON文件:", path)
		return{}
	return data
	
