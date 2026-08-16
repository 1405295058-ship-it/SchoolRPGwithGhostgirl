extends CharacterBody2D
class_name NPCBase


var face_dir: Vector2 = Vector2.DOWN
var state_machine: NPCStateMachine

@export var on_class_seat_id: String


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	call_deferred("set_up_state_machine")
	
	EventBus.class_start.connect(on_class_start)

func on_class_start():
	state_machine.change_state("on_class_state",{})

func _process(delta: float) -> void:
	if state_machine != null:
		state_machine.update(delta)


func set_up_state_machine() -> void:
	state_machine = NPCStateMachine.new(self)


func change_npc_state(state_name: StringName,data: Dictionary = {}) -> void:
	if state_machine == null:
		push_error("%s 的 state_machine 是 null" % name)
		return

	state_machine.change_state(state_name, data)


func play_animation(anim_name: StringName) -> bool:
	if not can_play_animation(anim_name):
		return false

	animated_sprite.play(anim_name)
	return true


func can_play_animation(anim_name: StringName) -> bool:
	if animated_sprite == null:
		push_error("%s 没有 AnimatedSprite2D" % name)
		return false

	if animated_sprite.sprite_frames == null:
		push_error("%s 没有 SpriteFrames" % name)
		return false

	if not animated_sprite.sprite_frames.has_animation(anim_name):
		push_error("%s 缺少动画：%s" % [name, anim_name])
		return false

	return true
	
func _play_animation_called_by_animation_player(anim_name:String):
	if not can_play_animation(anim_name):
		return
	animated_sprite.play(anim_name)

func get_face_direction_name() -> StringName:
	match face_dir:
		Vector2.UP:
			return &"up"
		Vector2.DOWN:
			return &"down"
		Vector2.LEFT:
			return &"left"
		Vector2.RIGHT:
			return &"right"

	return &"down"


func get_nodes_in_current_scene_group(group_name: StringName) -> Array[Node]:
	var result: Array[Node] = []
	var current_scene := get_tree().current_scene
	if current_scene == null:
		push_error("current_scene 是 null")
		return result
	for node in get_tree().get_nodes_in_group(group_name):
		if node == current_scene or current_scene.is_ancestor_of(node):
			result.append(node)
	return result


func find_node_by_id_in_group(group_name: StringName,target_id: String) -> Node:
	if target_id.is_empty():
		return null
	for node in get_nodes_in_current_scene_group(group_name):
		if not "ID" in node:
			continue
		if str(node.ID) == target_id:
			return node
	return null


func _exit_tree() -> void:
	if state_machine != null:
		state_machine.shutdown()
		state_machine = null

func find_class_seat() -> Node:
	return find_node_by_id_in_group(&"blue_chair",on_class_seat_id)
