extends NPCState
class_name IdleState


var idle_extra_running := false
var idle_generation := 0

var breath_tween: Tween
var is_idle_extra_playing := false
var idle_extra_timer_running := false

var max_animation_extra_waiting_time := 10.0
var min_animation_extra_waiting_time := 5.0


func enter(data: Dictionary = {}) -> void:
	if npc is CharacterBody2D:
		npc.velocity = Vector2.ZERO

	if data.has("face_dir"):
		npc.face_dir = data["face_dir"]

	play_idle_animation()

	idle_extra_running = true
	idle_generation += 1

	# 保存本次进入 Idle 的编号。
	# 即使退出后旧的 await 醒来，也能知道自己已经失效。
	var current_generation := idle_generation
	start_random_idle_extra(current_generation)


func update(_delta: float) -> void:
	pass


func exit() -> void:
	idle_extra_running = false
	idle_extra_timer_running = false
	is_idle_extra_playing = false

	# 让之前启动的异步流程失效。
	idle_generation += 1


func play_idle_animation() -> void:
	var anim_name := get_idle_animation_name(npc.face_dir)

	if npc.can_play_animation(anim_name):
		npc.play_animation(anim_name)
	elif npc.can_play_animation("idle_down"):
		npc.play_animation("idle_down")


func play_random_idle_extra(generation: int) -> void:
	if not is_idle_state_valid(generation):
		return

	is_idle_extra_playing = true

	var face_direction: String = npc.get_face_direction_name()
	var effect_name := "breath"
	var anim_name := "idle" + face_direction + "_" + effect_name

	if npc.animated_sprite == null:
		is_idle_extra_playing = false
		return

	if npc.animated_sprite.sprite_frames == null:
		is_idle_extra_playing = false
		return

	if not npc.animated_sprite.sprite_frames.has_animation(anim_name):
		is_idle_extra_playing = false
		return

	npc.animated_sprite.play(anim_name)

	await npc.animated_sprite.animation_finished

	# 动画播放期间可能已经切换到了其他状态。
	if not is_idle_state_valid(generation):
		is_idle_extra_playing = false
		return

	is_idle_extra_playing = false
	play_idle_animation()


func start_random_idle_extra(generation: int) -> void:
	if idle_extra_timer_running:
		return

	idle_extra_timer_running = true

	while is_idle_state_valid(generation):
		var waiting_time := randf_range(
			min_animation_extra_waiting_time,
			max_animation_extra_waiting_time
		)

		await npc.get_tree().create_timer(waiting_time).timeout

		# Timer 等待期间可能已经离开 Idle。
		if not is_idle_state_valid(generation):
			break

		if can_play_idle_extra():
			await play_random_idle_extra(generation)

	idle_extra_timer_running = false


func can_play_idle_extra() -> bool:
	if not idle_extra_running:
		return false

	if is_idle_extra_playing:
		return false

	if npc is CharacterBody2D:
		if npc.velocity != Vector2.ZERO:
			return false

	return true


func is_idle_state_valid(generation: int) -> bool:
	if not idle_extra_running:
		return false

	if generation != idle_generation:
		return false

	return true


func get_idle_animation_name(direction: Vector2) -> String:
	if direction == Vector2.UP:
		return "idle_up"

	if direction == Vector2.LEFT:
		return "idle_left"

	if direction == Vector2.RIGHT:
		return "idle_right"

	return "idle_down"
