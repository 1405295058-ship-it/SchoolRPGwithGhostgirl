extends Node2D
var animation_data_path ={
	door_type.teaching_area:"res://Tres_animation_file/DoorAnimation/TeachingAreaDoorAnimation.tres",
	door_type.accommodation:"res://Tres_animation_file/DoorAnimation/accommodationdoor.tres"
}

enum door_type{
	teaching_area,
	accommodation
}

enum facing {
	Left,
	Right
}

@export var is_open = true
@export var type_of_this_door:door_type = door_type.teaching_area
@export var facing_dir:facing = facing.Right
func _ready() -> void:
	initialise_the_door()
	match_door_animation()
	
	

func interact(_player):
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
		$AnimatedSprite2D.play("idle_open")	
		$Collision/CollisionShape2D.disabled = true
	else:
		$AnimatedSprite2D.play("idle_close")	
		$Collision/CollisionShape2D.disabled = false
func match_door_animation():
	$AnimatedSprite2D.sprite_frames = null
	var animation_path = animation_data_path[type_of_this_door]
	var animation_file = load(animation_path)
	$AnimatedSprite2D.sprite_frames = animation_file
	if $AnimatedSprite2D.sprite_frames == null:
		push_error("没有动画")

func close_door():
	$AnimatedSprite2D.play("close_door")
	$Collision/CollisionShape2D.disabled = false
func open_door():
	$AnimatedSprite2D.play("open_door")
	$Collision/CollisionShape2D.disabled = true	
			
