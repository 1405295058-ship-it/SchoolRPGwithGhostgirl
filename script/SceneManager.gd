extends Node

var next_spawn_id:String  = ""
var enter_animation_facing_dir:Vector2
func change_scene_to(scene_path , spawn_id,enter_animation_facing_dir_):
	next_spawn_id = spawn_id
	enter_animation_facing_dir = enter_animation_facing_dir_
	get_tree().change_scene_to_file(scene_path)
	
