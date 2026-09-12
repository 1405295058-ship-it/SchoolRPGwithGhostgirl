extends CharacterBody2D
class_name Player

var current_interact_object : Array[Node] = []

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
var face_dir := Vector2.DOWN  # 给个默认朝向，别用 ZERO
var correctVector = Vector2(20.0,20.0)

var is_idle_extra_playing := false
var idle_extra_timer_running := false
var ANIMATION_EXTRA_TIMER_WAITING_TIME = 3


func _ready() -> void:
	EventBus.start_play_cg.connect(on_cg_start_play)
	EventBus.end_play_cg.connect(on_cg_stop_play)
	hide_interact_hint()
	add_to_group("player")
	connect_interaction_signals()
	start_random_idle_extra()
	
#每一帧进行一次
func _process(_delta: float) -> void:
	camera_zoom()
	should_dialog()
	
		
#每一帧进行一次 有物理计算
func _physics_process(_delta):
	if cg_is_playing == false:
		player_movement()
		update_animation()
		
		
#===================== 统一交互系统 =================


#把player的interactArea 信号连接到统一交互系统，在player._ready()调用		
func connect_interaction_signals() -> void:
	if not InteractArea.body_entered.is_connected(_on_interact_area_body_entered):
		InteractArea.body_entered.connect(_on_interact_area_body_entered)
		
	if not InteractArea.body_exited.is_connected(_on_interact_area_body_exited):
		InteractArea.body_exited.connect(_on_interact_area_body_exited)
		
	if not InteractArea.area_entered.is_connected(_on_interact_area_area_entered):
		InteractArea.area_entered.connect(_on_interact_area_area_entered)
		
	if not InteractArea.area_exited.is_connected(_on_interact_area_area_exited):
		InteractArea.area_exited.connect(_on_interact_area_area_exited)
		
#监听interaction 选择最合适的对象调用interact(self)，在player._process调用
func should_dialog() -> void:
	
	if DialogBox.is_in_dialog or DialogBox.just_closed:
		return

	if GameStateManager.lock_interact:
		return

	if not Input.is_action_just_pressed("Interaction"):
		return
		
	var target := get_best_interaction_target()
	
	if target == null:
		return
	
	if target.has_method("interact"):
		target.interact(self)
		
#从可交互对象中选出本次交互对象， 在should_dialog()调用		
func get_best_interaction_target() -> Node:
	cleanup_interaction_objects()
	
	if current_interact_object.is_empty():
		return null
		
	var best_target : Node = null
	var best_priority := -999999
	var best_distance := INF
	
	for target in current_interact_object:
		if not is_interactable_valid(target):
			continue
			
		var priority := get_interaction_priority(target)
		var distance := global_position.distance_squared_to((target as Node2D).global_position)
		if priority > best_priority:
			best_target = target
			best_priority = priority
			best_distance = distance
			continue
			
		if priority == best_priority and distance < best_distance:
			best_target = target
			best_distance = distance
			
	return best_target
		
#定义不同交互对象的优先级，在get_best_interaction_target()调用
func get_interaction_priority(target : Node) -> int:
	if target is WorldItem:
		return 100
	
	return 0
	
#清理已经queue_free或失效的交互对象，在get_best_interaction_target()调用
func cleanup_interaction_objects() -> void:
	for index in range(current_interact_object.size() - 1, -1, -1):
		var target := current_interact_object[index]
		
		if not is_interactable_valid(target):
			current_interact_object.remove_at(index)
			
		refresh_interaction_hint()

#判断目标是否还能交互，在cleanup_interaction_objects()调用
func is_interactable_valid(target : Node) -> bool:
	if target == null:
		return false
		
	if not is_instance_valid(target):
		return false
		
	if target.is_queued_for_deletion():
		return false
		
	if not target is Node2D:
		return false
		
	if not target.has_method("interact"):
		return false
		
	return true
	
#把一个对象加入player可交互列表, 在Body_entered， area_entered调用
func register_interaction_object(target : Node) -> void:
	if target == null:
		return
	
	if not target.has_method("interact"):
		return
		
	if current_interact_object.has(target):
		return
		
	current_interact_object.append(target)
	
	refresh_interaction_hint()
	
#删除可交互列表中离开范围的对象,  在Body_entered， area_entered调用
func unregister_interaction_object(target : Node) -> void:
	if target == null:
		return

	current_interact_object.erase(target)

	refresh_interaction_hint()

#根据当前是否仍然存在可交互对象决定显示或隐藏交互提示, 在register_interaction_object(),unregister_interaction_object()
#cleanup_interaction_objects()调用
func refresh_interaction_hint() -> void:
	if current_interact_object.is_empty():
		hide_interact_hint()
		return

	show_interact_hint()
			
func _on_interact_area_body_entered(body : Node2D) -> void:
	register_interaction_object(body)
	
func _on_interact_area_body_exited(body: Node2D) -> void:
	unregister_interaction_object(body)
	
func _on_interact_area_area_entered(area : Area2D) -> void:
	register_interaction_object(area)
	
func  _on_interact_area_area_exited(area : Area2D) -> void:
	unregister_interaction_object(area)
	
#=================== CG ===========================
	
	
func on_cg_start_play():
	cg_is_playing = true
	
func on_cg_stop_play(_anim_name):
	cg_is_playing = false
	enable_player_camera()

#========================= player movement =========================

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

#================ idle extra animation ======================

			
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


#=================== chair ====================


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
	
func stand_from_chair()	:
	player_current_state = Player_states.normal
	var collision = current_chair.get_node("Collision")
	collision.disabled = false
	
	
#================== direction/ hint/ camera =======================
	
	
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

func hide_interact_hint() -> void:
	print(">>> hide_interact_hint()执行")
	$InteractHint.hide()
	
func show_interact_hint():
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
	
