extends Node2D
class_name MainMenu


@export var scene_name:String =  ""
@export var scene_id:String =  ""

@onready var cg_director = $CgDirector
@onready var canvas_modulate:CanvasModulate

func _ready() -> void:
	find_canvas_modulate()
	EnvironmentLayer.register_canvas_modulate(canvas_modulate)
	EventBus.play_this_animation.emit("Start_Animation",false)



func find_canvas_modulate():
	for child in get_children():
		if child is CanvasModulate:
			canvas_modulate = child
			return
	print("这个场景没有CanvasModulate")
