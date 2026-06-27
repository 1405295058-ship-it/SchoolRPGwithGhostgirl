extends StaticBody2D


enum FacingDir{
	down,
	up,
	right,
	left
}


var animation_name = ""
@export var facing = FacingDir.down

func _ready() -> void:
	update_sit_animation_name()
	choose_mark()
			
func choose_mark():
	if facing == FacingDir.up:
		$SitTarget.position = $SitBackTarget.position

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
	
