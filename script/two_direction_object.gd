extends StaticBody2D

enum FacingDir{
	right,
	left
}

@export var facing_direction = FacingDir.right

func _ready() -> void:
	match facing_direction:
		FacingDir.left:
			scale.x = -1
