# npc_data.gd
extends Resource
class_name NPCData

@export_category("基本资料")
@export var NPC_name = ""
@export var ID = ""

@export_category("对话")
@export_file("*.json") var dialog_json_path = ""
@export var default_dialog: Array = [
	{
		"speaker":"Mike",
		"text": "嘿！这不是nige吗？",
		"emotion": "normal"
	}
]


@export_category("美术")
@export var sprite_frame: SpriteFrames
