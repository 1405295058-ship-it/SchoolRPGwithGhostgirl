#fade_layer
extends CanvasLayer
@onready var black_rect:ColorRect = $ColorRect

var is_fade := false

var fade_tween:Tween

func _ready() -> void:
	

	black_rect.modulate.a = 0.0
	black_rect.visible = false
	
func fade_out(duration:float):
	EventBus.fade_start.emit()
	is_fade =true
	black_rect.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(black_rect,"modulate:a",1.0,duration)
	await fade_tween.finished
	EventBus.fade_end.emit()
func fade_in(duration:float):
	EventBus.fade_start.emit()
	is_fade =true
	black_rect.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(black_rect,"modulate:a",0,duration)
	await fade_tween.finished
	EventBus.fade_end.emit()
func fade_transition(fade_in_duration:float,fade_out_duration:float,holding_time:float):
	await fade_out(fade_out_duration)
	await get_tree().create_timer(holding_time).timeout
	await fade_in(fade_in_duration)
func set_black_screen():
	black_rect.visible = true
	black_rect.modulate.a = 1
	


	
