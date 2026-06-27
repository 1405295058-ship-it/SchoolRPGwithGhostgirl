extends Node2D

func _ready() -> void:
	EventBus.change_day_period.connect(update_light)
	update_light()
func close_light():
	$PointLight2D.hide()
func open_light():
	$PointLight2D.show()
func update_light():
	var current_day_period = TimeManager.current_day_period
	match current_day_period:
		"night_time":
			open_light()
		"lunch_time":
			close_light()
		"dinner_time":
			open_light()
		"morning":	
			close_light()
			
