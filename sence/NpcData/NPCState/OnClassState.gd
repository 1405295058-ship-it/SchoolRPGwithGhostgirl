extends NPCState
class_name OnClassState

var seat:Node

func enter(_data:Dictionary) -> void:
	seat = npc.find_class_seat()
	if seat == null:
		return
	
	npc.collision_shape.disabled = true
	
	var sit_position = seat.get_sit_target().global_position
	npc.global_position = sit_position
	
	var delay = randf_range(0.3, 0.8)
	await npc.get_tree().create_timer(delay).timeout
	
	if npc is BasicImportantNPC:
		npc.play_animation("on_class_animation")
	if npc is BackGroundNPC:
		var gender = npc.get_gender()
		if gender == null:
			push_error("有上课npc没有性别")
			return
		npc.play_animation(gender+"_on_class_animation")						

func update(_delta:float)->void:
	pass


func exit()->void:
	npc.collision_shape.disabled = false
