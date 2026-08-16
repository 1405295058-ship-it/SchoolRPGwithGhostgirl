extends NPCState
class_name BackgroundIdleState
@export var npc_preload = preload("res://sence/需要path的/back_ground_npc.tscn")


var all_character_type = [
	"boy",
	"girl"
]
var all_state = [
	"idle",
	"talk"
]




func enter(_data:Dictionary) -> void:
	
	var dir = vec_to_string(npc.face_dir) 
	
	var character_type = all_character_type.pick_random()
	
	var state = all_state.pick_random()
	
	var anim_name = "%s_%s_%s" % [
	character_type,
	state,
	dir
	]
	
	npc.play_animation(anim_name)
func update(_delta:float)->void:
	pass

func vec_to_string(face_dir:Vector2)->String:
	match face_dir:
		Vector2.UP:
			return "up"
		Vector2.DOWN:
			return "down"
		Vector2.RIGHT:
			return "right"
		Vector2.LEFT:
			return "left"
	return "down"
	
