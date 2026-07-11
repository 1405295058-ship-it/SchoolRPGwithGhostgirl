extends PointLight2D

var velocity:Vector2
var x_speed:float
var maximum_velocity = 2000


func _ready() -> void:
	x_speed = randf() * maximum_velocity
	velocity.x = x_speed
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position -= delta * velocity
