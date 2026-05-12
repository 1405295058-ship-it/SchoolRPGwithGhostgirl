extends StaticBody2D

@export var spawn_id:String
@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_id: String
@export var enter_animation_facing_dir:Vector2

func interact(player):
	SceneManager.change_scene_to(target_scene_path,target_spawn_id,enter_animation_facing_dir)
