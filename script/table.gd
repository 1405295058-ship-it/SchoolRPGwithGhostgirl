extends StaticBody2D


enum FacingDir{
	down,
	up,
	right,
	left
}

@export var facing = FacingDir.down

func _ready() -> void:
	initialize_face_dir()

func initialize_face_dir():
		match facing:
			FacingDir.down:
				$AnimatedSprite2D.play("down")
			FacingDir.up:
				$AnimatedSprite2D.play("up")
			FacingDir.right:
				$AnimatedSprite2D.play("right")
			FacingDir.left:
				$AnimatedSprite2D.play("left")
