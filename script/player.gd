extends CharacterBody2D
class_name Player

var current_interact_object = []
var cg_is_playing :=false

var ID = "player"

enum Player_states{
	normal,
	siting
}
var player_current_state = Player_states.normal

var current_chair = null

@export var walk_speed = 1 
@export var ran_speed = 2 
var _speed = 1
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var InteractArea = $AnimatedSprite2D/InteractArea
@onready var player_camera:Camera2D = $Camera2D
@onready var interact_hint:AnimatedSprite2D = $InteractHint
var face_dir := Vector2.DOWN  # 给个默认朝向，别用 ZERO
var correctVector = Vector2(20.0,20.0)

var is_fading := false
var is_idle_extra_playing := false
var idle_extra_timer_running := false
var ANIMATION_EXTRA_TIMER_WAITING_TIME = 3


func _ready() -> void:
	EventBus.start_play_cg.connect(on_cg_start_play)
	EventBus.end_play_cg.connect(on_cg_stop_play)
	EventBus.fade_start.connect(on_fade_start)
	EventBus.fade_end.connect(on_fade_end)
	hide_interact_hint()
	add_to_group("player")
	start_random_idle_extra()

func on_fade_start():
	is_fading = true
func on_fade_end():
	is_fading = false

func on_cg_start_play():
	cg_is_playing = true
	interact_hint.hide()
func on_cg_stop_play(_anim_name):
	cg_is_playing = false
	enable_player_camera()


#每一帧进行一次
func _process(_delta: float) -> void:
	camera_zoom()
	should_dialog()
	
func start_random_idle_extra():
	if idle_extra_timer_running:
		return
	idle_extra_timer_running = true
	
	while true:
		await get_tree().create_timer(randf_range(1,ANIMATION_EXTRA_TIMER_WAITING_TIME)).timeout
		if can_play_idle_extra():
			play_random_idle_extra()	
	
	
func can_play_idle_extra()->bool:
	if velocity != Vector2.ZERO:
		return false
	if player_current_state != Player_states.normal:
		return false
	if cg_is_playing:
		return false
	
	return true
	
func play_random_idle_extra():
	is_idle_extra_playing = true
	
	var face_direction = get_face_direction()
	var effect_name := "_blink" if randf() <0.75 else "_breath"
	
	var anim_name = "idle" + face_direction + effect_name
	
	anim.play(anim_name)
	await anim.animation_finished
	
	if velocity == Vector2.ZERO:
		is_idle_extra_playing = false
		
	
#每一帧进行一次 有物理计算
func _physics_process(_delta):
	if can_input_or_interact():
		player_movement()
		update_animation()

#移动
func player_movement():
	var input_dir = Input.get_vector("vi_left", "vi_right", "vi_up", "vi_down")
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("sprint"):
		_speed = ran_speed
	else:
		_speed = walk_speed
	if player_current_state == Player_states.siting:
		if input_dir != Vector2.ZERO:
			stand_from_chair()
	
	if player_current_state == Player_states.normal:	
		if Input.is_action_pressed("vi_right"):
			velocity.x = 1 
			face_dir = Vector2.RIGHT
			InteractArea.position = face_dir * correctVector
		if Input.is_action_pressed("vi_left"):
			velocity.x = -1
			face_dir = Vector2.LEFT
			InteractArea.position = face_dir* correctVector
		if Input.is_action_pressed("vi_up"):
			velocity.y = -1
			face_dir = Vector2.UP
			InteractArea.position = face_dir* correctVector
		if Input.is_action_pressed("vi_down"):
			velocity.y = 1
			face_dir = Vector2.DOWN
			InteractArea.position = face_dir* correctVector
		velocity =  velocity.normalized() * _speed
		move_and_slide()
		global_position = global_position.round()
		$Camera2D.global_position = global_position.round()
#走路动画
func update_animation():
	var is_moving := velocity != Vector2.ZERO
	if is_idle_extra_playing and is_moving:
		is_idle_extra_playing = false
	elif is_idle_extra_playing:
		return
	
	var moving = false
	if Input.is_action_just_pressed("happy"):
		anim.play("player_happy")
		
	
		
	if player_current_state == Player_states.normal:	
		if velocity != Vector2.ZERO:
			moving = true
		if velocity == Vector2.ZERO:
			moving = false
		if face_dir == Vector2.RIGHT:
			anim.play("walk_right" if moving else "idle_right")
		elif face_dir == Vector2.LEFT:
			anim.play("walk_left" if moving else "idle_left")
		elif face_dir == Vector2.UP:
			anim.play("walk_up" if moving else "idle_up")
			
		elif face_dir == Vector2.DOWN:
			anim.play("walk_down" if moving else "idle_down")
			
#相机缩放
func camera_zoom():
	camera.global_position = global_position.round()
	var step := 0.01
	var min_zoom := 0.25
	var max_zoom := 1

	if Input.is_action_just_pressed("wheel_up"):
		camera.zoom.x = clamp(camera.zoom.x - step, min_zoom, max_zoom)
		camera.zoom.y = camera.zoom.x

	elif Input.is_action_just_pressed("wheel_down"):
		camera.zoom.x = clamp(camera.zoom.x + step, min_zoom, max_zoom)
		camera.zoom.y = camera.zoom.x


	
	
	#这是判断是不是可以说话的npc然后用default dialoge对话
func should_dialog():
	if not can_input_or_interact():
		return


	if Input.is_action_just_pressed("Interaction"):
		

		if current_interact_object.is_empty():
			return

		var target = current_interact_object[0]

		if target.has_method("interact"):
			target.interact(self)
		elif target.get_parent() and target.get_parent().has_method("interact"):
			target.get_parent().interact(self)
		else:
			print("target has no interact:", target)
		
	

#判断有没有NPC在interactarea里面
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.has_method("interact"):
		show_interact_hint()
	current_interact_object.append(body)

func _on_interact_area_body_exited(body: Node2D) -> void:
	hide_interact_hint()
	current_interact_object.erase(body)
	
#呼叫userUI
func get_face_direction():
	if face_dir == Vector2.UP:
		return "_up"
	if face_dir == Vector2.DOWN:
		return "_down"
	if face_dir == Vector2.LEFT:
		return "_left"
	if face_dir == Vector2.RIGHT:
		return "_right"
	return "_down"

func sit_on_seat(chair):
	current_chair = null
	current_chair = chair
	var sit_ani_name = current_chair.animation_name
	var seat_mark = current_chair.get_node("SitTarget")
	var seat_position = seat_mark.global_position
	var collision = current_chair.get_node("Collision")
	collision.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", seat_position, 0.25)
	await tween.finished
	player_current_state = Player_states.siting
	$AnimatedSprite2D.play(sit_ani_name)

func player_sit_on_chair(chair_id: String):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("CG找不到player")
		return
	
	var chairs = get_tree().get_nodes_in_group("blue_chair")
	
	for chair in chairs:
		if chair.ID == chair_id:
			player.sit_on_seat(chair)
			return
	
	push_error("找不到椅子: ", chair_id)

func stand_from_chair()	:
	player_current_state = Player_states.normal
	var collision = current_chair.get_node("Collision")
	collision.disabled = false
func hide_interact_hint():
	$InteractHint.hide()
func show_interact_hint():
	if cg_is_playing == true:
		return
	$InteractHint.show()
	$InteractHint.play("default")

func disable_player_camera():
	player_camera.enabled = false
func enable_player_camera():
	player_camera.enabled = true
	player_camera.make_current()

func _play_animation_called_by_animation_player(anim_name:String):
	if not $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		push_error(ID,"没有这个动画名: ",anim_name)
		return
	$AnimatedSprite2D.play(anim_name)

func can_input_or_interact()->bool:
	if is_fading :
		return false
	if cg_is_playing:
		return false
	if DialogBox.is_in_dialog or DialogBox.just_closed:
		return false	
	
	return true
	
