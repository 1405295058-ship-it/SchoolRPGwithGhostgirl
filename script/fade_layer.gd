#fade_layer
extends CanvasLayer
@onready var black_rect:ColorRect = $ColorRect

var is_fade = false

func _ready() -> void:
	black_rect.modulate.a = 0.0
	black_rect.visible = false
	
func fade_out(duration:float):
	GameStateManager.lock_interaction()
	is_fade =true
	black_rect.visible = true
	var tween = create_tween()
	tween.tween_property(black_rect,"modulate:a",1.0,duration)
	await tween.finished
func fade_in(duration:float):
	is_fade =true
	black_rect.visible = true
	var tween = create_tween()
	tween.tween_property(black_rect,"modulate:a",0,duration)
	await tween.finished
	GameStateManager.unlock_interaction()
func fade_transition(fade_in_duration:float,fade_out_duration:float,holding_time:float):
	await fade_out(fade_out_duration)
	await get_tree().create_timer(holding_time).timeout
	await fade_in(fade_in_duration)
