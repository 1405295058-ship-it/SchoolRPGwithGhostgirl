extends Path2D

@export var sun_light_sprite_path := preload("res://sence/需要path的/sun_light_sprite.tscn")

@onready var path_follow = $PathFollow2D

var maximum_light := 2

var current_light := 0

func _process(delta: float) -> void:
	if current_light < maximum_light:
		create_light()
	
func create_light():
	path_follow.progress_ratio = randf()
	var sun_light_sprite = sun_light_sprite_path.instantiate()
	sun_light_sprite.global_position = path_follow.global_position
	add_child(sun_light_sprite)
	current_light += 1
	create_timer_for_light(sun_light_sprite)
	
func create_timer_for_light(sun_light_sprite):
	var timer  = get_tree().create_timer(30)
	await timer.timeout
	sun_light_sprite.queue_free()
	current_light -= 1
