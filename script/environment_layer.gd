extends CanvasLayer

var current_modulate: CanvasModulate

var color_map = {
	"morning": Color(0.78, 0.82, 0.88),
	"lunch_time": Color(1, 1, 1),
	"dinner_time": Color(0.956, 0.663, 0.580),
	"night_time": Color(0.353, 0.392, 0.627)
}

func _ready() -> void:
	EventBus.change_day_period.connect(update_current_layer)
	update_current_layer()

func register_canvas_modulate(canvas_modulate: CanvasModulate):
	current_modulate = canvas_modulate
	update_current_layer()

func update_current_layer():
	if current_modulate == null:
		return
	
	if is_now_in_main_menu():
		effect_for_main_menu()
		return
		
	var target_color = color_map.get(TimeManager.current_day_period, Color(1, 1, 1))
	current_modulate.color = target_color


func is_now_in_main_menu()->bool:
	var current_scene_id = get_tree().current_scene.scene_id
	if current_scene_id == "MainMenu":
		return true
	return false
	

func effect_for_main_menu():
	var target_color = color_map["night_time"]
	current_modulate.color = target_color
