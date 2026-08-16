extends StaticBody2D

@export var ID = ""

enum FacingDir{
	down,
	up,
	right,
	left
}
@onready var sit_target = $SitTarget

var animation_name = ""
@export var facing = FacingDir.down


func _ready() -> void:
	initialize_face_dir()
	update_sit_animation_name()
	choose_mark()

func get_sit_target():
	return sit_target
			
func choose_mark():
	if facing == FacingDir.up:
		$SitTarget.position = $SitBackTarget.position

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

func update_sit_animation_name():
	match facing:
			FacingDir.down:
				animation_name = "sit_down"
			FacingDir.up:
				animation_name = "sit_up"
			FacingDir.right:
				animation_name = "sit_right"
			FacingDir.left:
				animation_name = "sit_left"
	return animation_name
	
func interact(player):
	player.sit_on_seat(self)
	
