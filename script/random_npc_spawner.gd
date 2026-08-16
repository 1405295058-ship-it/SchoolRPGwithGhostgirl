extends Marker2D

@export var facing_dir:face_dir
enum face_dir{
	up,
	down,
	right,
	left
}
@export var npc_preload = preload("res://sence/需要path的/back_ground_npc.tscn")


func _ready() -> void: 
	creat_npc()

func creat_npc():
	
	
	var background_npc = npc_preload.instantiate()
	get_parent().add_child.call_deferred(background_npc)
	background_npc.face_dir = get_dir_vec(facing_dir)
	background_npc.global_position = global_position
	await background_npc.ready
	await get_tree().create_timer(randf_range(0,1)).timeout
	background_npc.change_npc_state("background_idle",{})
	
	
	
	
	

func get_dir_vec(facing_direction:face_dir)->Vector2:
	match facing_direction:
		face_dir.up:
			return Vector2.UP
		face_dir.down:
			return Vector2.DOWN
		face_dir.right:
			return Vector2.RIGHT
		face_dir.left:
			return Vector2.LEFT
	return Vector2.DOWN
