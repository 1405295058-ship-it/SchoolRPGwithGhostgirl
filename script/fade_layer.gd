#fade_layer
extends CanvasLayer
@onready var black_rect:ColorRect = $ColorRect

var is_fade = false

var fade_tween:Tween

func _ready() -> void:
	EventBus.cg_start_fast_forward.connect(on_cg_start_fast_play)
	EventBus.end_play_cg.connect(on_cg_end_fade_in)
	black_rect.modulate.a = 0.0
	black_rect.visible = false
	
func fade_out(duration:float):
	GameStateManager.lock_interaction()
	is_fade =true
	black_rect.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(black_rect,"modulate:a",1.0,duration)
	await fade_tween.finished
func fade_in(duration:float):
	is_fade =true
	black_rect.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(black_rect,"modulate:a",0,duration)
	await fade_tween.finished
	GameStateManager.unlock_interaction()
func fade_transition(fade_in_duration:float,fade_out_duration:float,holding_time:float):
	await fade_out(fade_out_duration)
	await get_tree().create_timer(holding_time).timeout
	await fade_in(fade_in_duration)
func set_black_screen():
	black_rect.visible = true
	black_rect.modulate.a = 1
func on_cg_start_fast_play():
	kill_fade_tween()
	black_rect.modulate.a = 0
	black_rect.visible = false

func on_cg_end_fade_in(_anim_name):
	black_rect.visible = false
	black_rect.modulate.a = 0
	
func kill_fade_tween():
	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = null
	
