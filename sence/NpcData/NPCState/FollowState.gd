extends NPCState
class_name FollowingState


var thing: Node2D
var follow_group: String = ""
var target_ID: String = ""

var stop_distance := 300.0
var teleport_distance := 5000.0
var follow_speed := 2.0


func enter(data: Dictionary = {}) -> void:
	follow_group = data.get("follow_group", "")
	target_ID = data.get("target_ID", "")

	thing = find_target(follow_group, target_ID)

	if thing == null:
		push_warning(
			"%s 没找到跟随目标：%s"
			% [npc.name, target_ID]
		)
		state_machine.change_state(&"idle")


func update(delta: float) -> void:
	follow_thing(delta)


func exit() -> void:
	thing = null

	if "velocity" in npc:
		npc.velocity = Vector2.ZERO


func follow_thing(delta: float) -> void:
	if thing == null or not is_instance_valid(thing):
		thing = find_target(follow_group, target_ID)

	if thing == null:
		state_machine.change_state(&"idle")
		return

	var offset: Vector2 = (
		thing.global_position -
		npc.global_position
	)

	var distance := offset.length()

	if distance == 0.0:
		return

	var direction := offset.normalized()

	npc.face_dir = get_cardinal_direction(direction)

	if distance > teleport_distance:
		npc.global_position = thing.global_position
		play_idle_animation(direction)
		return

	if distance < stop_distance:
		play_idle_animation(direction)
		return

	npc.global_position = npc.global_position.lerp(
		thing.global_position,
		follow_speed * delta
	)

	npc.global_position = npc.global_position.round()

	update_following_animation(direction)


func find_target(
	group: String,
	target_id: String
) -> Node2D:
	for object in npc.get_tree().get_nodes_in_group(group):
		if not object is Node2D:
			continue

		if "ID" not in object:
			continue

		if object.ID == target_id:
			return object

	return null


func update_following_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			npc.play_animation("walk_right")
		else:
			npc.play_animation("walk_left")
	else:
		if dir.y > 0:
			npc.play_animation("walk_down")
		else:
			npc.play_animation("walk_up")


func play_idle_animation(dir: Vector2) -> void:
	if npc.animated_sprite == null:
		npc.animated_sprite = npc.get_node_or_null(
			"AnimatedSprite2D"
		)

	if npc.animated_sprite == null:
		push_error(
			"NPC没有 AnimatedSprite2D：",
			npc.ID
		)
		return

	if npc.animated_sprite.sprite_frames == null:
		push_error(
			"NPC没有 SpriteFrames：",
			npc.ID
		)
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			npc.play_animation("idle_right")
		else:
			npc.play_animation("idle_left")
	else:
		if dir.y > 0:
			npc.play_animation("idle_down")
		else:
			npc.play_animation("idle_up")


func get_cardinal_direction(
	direction: Vector2
) -> Vector2:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			return Vector2.RIGHT
		return Vector2.LEFT

	if direction.y > 0:
		return Vector2.DOWN

	return Vector2.UP
