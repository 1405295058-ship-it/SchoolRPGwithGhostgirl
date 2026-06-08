extends CharacterBody2D
class_name BasicImportantNPC

@export var NPC_name = ""
@export var ID = ""
@export_file("*.json") var dialog_json_path = ""
@export var face_map: Dictionary = {
	"normal": "res://art/face/Mike说话.png"
}
@export var sprite_frame: SpriteFrames

@onready var animated_sprite = $AnimatedSprite2D


var following = false
var follow_group = ""
var follow_ID = ""

@export var defult_dialog: Array = [
	{
		"speaker":"Mike",
		"text": "嘿！这不是nige吗？",
		"emotion": "normal"
	}
]

var dialog_data = {}
var current_dialog_list = []

func _ready() -> void:
	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)
	animated_sprite.sprite_frames = sprite_frame
	animated_sprite.play("idel_down")
	load_from_json()
	current_dialog_list = QuestManager.update_character_dialoglist(dialog_data)
	QuestManager.quest_hint_should_refresh.connect(refresh_quest_hint)
func _process(delta: float) -> void:
	if following:
		follow_thing()

func interact(player):
	current_dialog_list = QuestManager.update_character_dialoglist(dialog_data)
	DialogBox.start_dialog(current_dialog_list, defult_dialog)
	var event_name = "talked_with_" + ID
	print(event_name)
	QuestManager.check_event_is_quest_need(event_name,1)

func follow_thing():
	var thing = find_target(follow_group, follow_ID)
	if thing == null:
		return
	
	var vector = thing.global_position - global_position
	var dir = vector.normalized()
	if vector.length() < 300.0:
		play_idle_animation(dir)
		
	else:
		
		global_position = global_position.lerp(thing.global_position,2*get_process_delta_time())
		global_position = global_position.round()
		update_following_animation(dir)
	

func find_target(group: String, target_id: String):
	for object in get_tree().get_nodes_in_group(group):
		if object.ID == target_id:
			return object
	return null

func load_from_json():
	if dialog_json_path == "":
		return
	
	var data = FileAccess.get_file_as_string(dialog_json_path)
	var parsed_data = JSON.parse_string(data)
	if parsed_data:
		dialog_data = parsed_data
	else:
		print("fail to parsed")

func update_following_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if dir.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")

func play_idle_animation(dir:Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("idel_right")
		else:
			animated_sprite.play("idel_left")
	else:
		if dir.y > 0:
			animated_sprite.play("idel_down")
		else:
			animated_sprite.play("idel_up")
func refresh_quest_hint():
	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)
	print(quest_status)
