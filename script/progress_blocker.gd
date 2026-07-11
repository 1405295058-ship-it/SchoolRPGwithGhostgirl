extends Node2D

@export var ID:String   #SceneName_PlaceDescription_Number
@export var enabled := false

@onready var trigger_area = $TriggerArea
@onready var collision_area =$CollisionArea

@export var warning_dialog := [
	{
		"speaker":"player",
		"text": "现在还不是走这边的时候。",
		"emotion": "normal"
	}
]

func _ready() -> void:
	EventBus.call_this_progress_blocker.connect(on_call_blocker)
	on_call_blocker(ID,enabled,[])
func on_call_blocker(blocker_id:String, action:bool,warning_dialog_change:Array):
	if not ID == blocker_id:
		return
	if warning_dialog_change.size() >0 :
		warning_dialog = warning_dialog_change	
	if action:
		active_the_blocker()
	else:
		disable_the_blocker()


func active_the_blocker():
	enabled = true
	$CollisionArea/CollisionShape2D.disabled = false
	trigger_area.monitoring = true
func disable_the_blocker():
	enabled = false
	$CollisionArea/CollisionShape2D.disabled = true
	trigger_area.monitoring = false



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		DialogBox.start_dialog([], warning_dialog)
