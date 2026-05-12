extends CharacterBody2D

var current_interact_object = []

var ID = "player"

enum Player_states{
	normal,
	siting
}
var player_current_state = Player_states.normal

var current_chair = null
@export var wallk_speed = 1 
@export var ran_speed = 2 
var _speed = 1
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var InteractArea = $AnimatedSprite2D/InteractArea
var face_dir := Vector2.DOWN  # 给个默认朝向，别用 ZERO
var correctVector = Vector2(20.0,20.0)



func _ready() -> void:
	add_to_group("player")

#每一帧进行一次
func _process(delta: float) -> void:
	camera_zoom()
	should_dialog()
	
	
	
	
		
	
#每一帧进行一次 有物理计算
func _physics_process(delta):
	player_movement()
	update_animation()

#移动
func player_movement():
	var input_dir = Input.get_vector("vi_left", "vi_right", "vi_up", "vi_down")
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("sprint"):
		_speed = ran_speed
	else:
		_speed = wallk_speed
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
	var moving = true
	if Input.is_action_just_pressed("happy"):
		anim.play("player_happy")
		
	
		
	if player_current_state == Player_states.normal:	
		if velocity != Vector2.ZERO:
			moving = true
		if velocity == Vector2.ZERO:
			moving = false
		if face_dir == Vector2.RIGHT:
			anim.play("walk_right" if moving else "idel_right")
		elif face_dir == Vector2.LEFT:
			anim.play("walk_left" if moving else "idel_left")
		elif face_dir == Vector2.UP:
			anim.play("walk_up" if moving else "idel_up")
			
		elif face_dir == Vector2.DOWN:
			anim.play("walk_down" if moving else "idel_down")
			
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


	
	
	#这是判断是不是可以说话的npc然后用defult dialoge对话
func should_dialog():
	
	if DialogBox.is_in_dialog or DialogBox.just_closed:
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
	current_interact_object.append(body)
	print(current_interact_object)

func _on_interact_area_body_exited(body: Node2D) -> void:
	current_interact_object.erase(body)
#呼叫userUI

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
	
