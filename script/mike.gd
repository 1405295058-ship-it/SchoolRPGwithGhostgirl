extends CharacterBody2D
class_name important_npc

@export var  dialog_json_path = "res://QuestResources/Dialog/MikeDialog.json"
@onready var MissionTask = $MissionTask 
@export var face_map = {
	"normal":"res://art/face/Mike说话.png",
	"happy":"res://art/face/Mike说话.png",
	"surprised":"res://art/face/Mike惊讶.png",
	"sad":"res://art/face/Mike说话.png",
	
}

const defult_dialog = 	[
							{
								"text":"嘿！这不是nige吗？",
								"emotion":"surprised"
							},
							{
								"text":"你也来报道啦？！",
								"emotion":"normal"
							},
							
						]

var dialog_data = {}
var current_dialog_list = []

func _ready() :
	MissionTask.hide()
	load_from_json()
	current_dialog_list =[]
	current_dialog_list = QuestManager.update_character_dialoglist(dialog_data)
	print(current_dialog_list )

func interact(player):
	DialogBox.start_dialog(current_dialog_list,face_map,defult_dialog)
	QuestManager.check_event_is_quest_need("talked_with_Mike")





func load_from_json():
	var data = FileAccess.get_file_as_string(dialog_json_path)
	var parsed_data = JSON.parse_string(data)
	if parsed_data :
		dialog_data = parsed_data
	else:
		print("fail to parsed")
		



	



func _on_interactable_area_entered(area: Area2D) -> void:
	MissionTask.show()

func _on_interactable_area_exited(area: Area2D) -> void:
	MissionTask.hide()
