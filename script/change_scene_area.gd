#change_scene_area
extends StaticBody2D

@export var ID:String
@export var target_scene_id: String
@export var target_spawn_id: String
@export var enter_animation_facing_dir:Vector2

@export var is_enable := true

@export var warning_dialog := [
	{
		"speaker":"player",
		"text": "现在还不是进去这边的时候。",
		"emotion": "normal"
	}
]





func _ready() -> void:
	EventBus.call_this_change_scene_area.connect(on_call_this_change_scene_area)

func interact(_player):
	if is_enable:
		SceneManager.change_scene_from_spawn(target_scene_id,target_spawn_id,enter_animation_facing_dir)
	else:
		DialogBox.start_dialog([],warning_dialog)
func on_call_this_change_scene_area(area_id:String,action:bool,warning_dialog_change:Array):
	if area_id != ID:
		return
	is_enable = action
	if warning_dialog_change.size() > 0:
		warning_dialog = warning_dialog_change
	
