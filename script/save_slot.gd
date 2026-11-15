extends Control
class_name SlotTab

@export var disp_name:String
@export var slot_id:String
@onready var button = $Button
@export var slot_type:SlotType

@onready var slot_id_disp = $Button/SlotID
@onready var empty_label = $Button/EmptySigh
@onready var save_time = $Button/SaveTime
@onready var time_label = $Button/TimeLabel
var can_load := false

enum SlotType {
	SAVE,
	LOAD
}

func _ready() -> void:
	slot_id_disp.text = slot_id
	update_slot.call_deferred()
	

func update_slot():
	refresh_can_load()
	if can_load:
		empty_label.hide()
		time_label.show()
		save_time.show()
		var time = get_save_time()
		save_time.text = time
	else:
		empty_label.show()
		save_time.hide()
		time_label.hide()
		
func _on_button_pressed() -> void:
	if slot_type == SlotType.SAVE:
		print("button按下 正在保存")
		await SaveManager.save_game_to_slot(slot_id)
	elif slot_type == SlotType.LOAD:
		print("button按下 正在读取")
		UserUi.close_user_UI()
		await SaveManager.load_game(slot_id)
	update_slot()

func refresh_can_load():
	can_load = SaveManager.can_slot_load(slot_id)
	

func get_save_time():
	return SaveManager.get_save_time(slot_id)
