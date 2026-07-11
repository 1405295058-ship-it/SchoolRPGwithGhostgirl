extends Marker2D

@export var facing_dir:face_dir
enum face_dir{
	up,
	down,
	right,
	left
}
@export var npc_preload = preload("res://sence/需要path的/back_ground_npc.tscn")
var all_character_type = [
	"boy",
	"girl"
]
var all_state = [
	"idle",
	"talk"
]

func _ready() -> void:
	creat_npc()

func creat_npc():
	var character_type = all_character_type.pick_random()
	var state = all_state.pick_random()
	var dir = get_dir_string(facing_dir)
	
	var background_npc = npc_preload.instantiate()
	get_parent().add_child.call_deferred(background_npc)
	background_npc.global_position = global_position
	var anim_name = "%s_%s_%s" % [
		character_type,
		state,
		dir
	]
	var time = randf_range(0,2)
	await get_tree().create_timer(time).timeout
	background_npc.play_animation(anim_name)
	
	

func get_dir_string(facing_direction:face_dir)->String:
	return ["up","down","right","left"][facing_direction]
