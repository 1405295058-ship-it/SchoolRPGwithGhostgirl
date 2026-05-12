extends Node2D

enum facing {
	Left,
	Right
}

@export var is_open = true

@export var facing_dir:facing = facing.Right
func _ready() -> void:
	initialise_the_door()
	
	

func interact(player):
	if is_open == true:
		close_door()
		is_open = false
	else:
		open_door()
		is_open = true

func initialise_the_door():
	match facing_dir:
		facing.Right:
			$AnimatedSprite2D.flip_h = false
		facing.Left:
			$AnimatedSprite2D.flip_h = true
	
	if is_open == true :
		$AnimatedSprite2D.play("idel_open")	
		$Collision/CollisionShape2D.disabled = true
	else:
		$AnimatedSprite2D.play("idel_close")	
		$Collision/CollisionShape2D.disabled = false

func close_door():
	$AnimatedSprite2D.play("close_door")
	$Collision/CollisionShape2D.disabled = false
func open_door():
	$AnimatedSprite2D.play("open_door")
	$Collision/CollisionShape2D.disabled = true	
			
