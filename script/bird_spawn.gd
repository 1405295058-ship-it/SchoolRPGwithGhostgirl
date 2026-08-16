extends Node2D

@export var facing_direction : face_dir

@onready var bird = $FlyPath/Bird
@onready var animated_sprite = $FlyPath/Bird/AnimatedSprite2D
@onready var animation_player = $FlyPath/Bird/AnimationPlayer


const RESET_TIME := 30

var is_fly := false
var is_in_animation := false

var face_dir_string: String


enum face_dir {
	down,
	up,
	left,
	right
}
func _ready() -> void:
	initialise_bird()
func _process(_delta: float) -> void:
	update_on_ground_animation()





func initialise_bird():
	bird.progress_ratio = 0
	face_dir_string = get_direction_animation_name()
func update_on_ground_animation()->void:
	if is_fly:
		return
	if is_in_animation:
		return
		
	var effect_name := "idle" if randf() <0.50 else "eat"
	var animation_name = effect_name + face_dir_string
	
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		push_error("没有动画名",animation_name)
		return
	animated_sprite.play(animation_name)
	is_in_animation = true
	var exist_time = randi_range(2,5)
	var timer = get_tree().create_timer(exist_time)
	await timer.timeout
	is_in_animation = false
	

func get_direction_animation_name() -> String:
	match facing_direction:
		face_dir.up:
			return "_up"
		face_dir.down:
			return "_down"
		face_dir.left:
			return "_left"
		face_dir.right:
			return "_right"
	return "_down"		
	
func progress_fly():
	if is_fly:
		return
	
	is_fly = true
	is_in_animation = false
	animated_sprite.play("fly")
	animation_player.play("fly_animation")
	await animation_player.animation_finished
	start_timer_for_replace()

	
	
func start_timer_for_replace():
	var timer = get_tree().create_timer(RESET_TIME)
	await timer.timeout
	is_fly = false
	initialise_bird()		


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	progress_fly()
