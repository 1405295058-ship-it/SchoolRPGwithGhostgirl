#basicimportantNPC
extends CharacterBody2D
class_name BasicImportantNPC

var breath_tween:Tween
var visual_origin_y = 0.0
@onready var animated_sprite = $AnimatedSprite2D
#npc基础数据
var NPC_name = ""
var ID = ""
var dialog_json_path = ""
var default_dialog: Array 
var sprite_frame: SpriteFrames

#npc的data_rescource
@export var npc_data:NPCData

#这里是npc行为相关的
var following = false
var follow_group = ""
var follow_ID = ""


var face_dir := Vector2.DOWN
var is_idle_extra_playing := false
var idle_extra_timer_running := false
var MAX_ANIMATION_EXTRA_TIMER_WAITING_TIME = 10
var MIN_ANIMATION_EXTRA_TIMER_WAITING_TIME = 5



var dialog_data = {}
var dialog_result = {}

func _ready() -> void:
	read_npc_data_resource()
	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)
	animated_sprite.sprite_frames = sprite_frame
	animated_sprite.play("idle_down")
	load_from_json()
	dialog_result = QuestManager.resolve_character_dialoglist(dialog_data,ID)
	EventBus.quest_hint_should_refresh.connect(refresh_quest_hint)
	
	start_random_idle_extra()
func read_npc_data_resource():
	if npc_data == null:
		push_error("有npc没有放resource")
	NPC_name = npc_data.NPC_name
	ID = npc_data.ID
	dialog_json_path = npc_data.dialog_json_path
	default_dialog = npc_data.default_dialog
	sprite_frame = npc_data.sprite_frame
	
func _process(_delta: float) -> void:
	if following:
		follow_thing()


	

func interact(_player):
	dialog_result = QuestManager.resolve_character_dialoglist(dialog_data,ID)
	DialogBox.start_dialog(
	 dialog_result["dialog_list"],
	 default_dialog,
	 dialog_result["start_talk_state"]
	)
	var event_name = "talked_with_" + ID
	print(event_name)
	
	QuestManager.check_event_is_quest_need(event_name,1)

func follow_thing():
	var thing = find_target(follow_group, follow_ID)
	if thing == null:
		return
	
	var vector = thing.global_position - global_position
	var dir = vector.normalized()
	if vector.length() >5000:
		global_position = thing.global_position
	if vector.length() < 300.0:
		play_idle_animation(dir)
		
	else:
		
		global_position = global_position.lerp(thing.global_position,2*get_process_delta_time())
		global_position = global_position.round()
		update_following_animation(dir)
	

func find_target(group: String, target_id: String):
	for object in get_tree().get_nodes_in_group(group):
		if object.ID == target_id:
			return object
	return null

func load_from_json():
	if dialog_json_path == "":
		return
	
	var data = FileAccess.get_file_as_string(dialog_json_path)
	var parsed_data = JSON.parse_string(data)
	if parsed_data:
		dialog_data = parsed_data
	else:
		print("fail to parsed")

func update_following_animation(dir: Vector2):
	if is_idle_extra_playing:
		is_idle_extra_playing =false
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if dir.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")
func apply_facing_dir(dir: Vector2):
	if not is_node_ready():
		await ready

	play_idle_animation(dir)

func play_idle_animation(dir:Vector2):
	if is_idle_extra_playing:
		return
		
	if animated_sprite == null:
		animated_sprite = get_node_or_null("AnimatedSprite2D")

	if animated_sprite == null:
		push_error("NPC没有 AnimatedSprite2D：", ID)
		return

	if animated_sprite.sprite_frames == null:
		push_error("NPC没有 SpriteFrames：", ID)
		return
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("idle_right")
		else:
			animated_sprite.play("idle_left")
	else:
		if dir.y > 0:
			animated_sprite.play("idle_down")
		else:
			animated_sprite.play("idle_up")
func refresh_quest_hint():
	var quest_status = QuestManager.get_hint_type_by_object_id(ID)
	$QuestHintMarker.update_hint_mark(quest_status)
	

	
func start_random_idle_extra():
	if idle_extra_timer_running:
		return
	idle_extra_timer_running = true
	
	while true:
		await get_tree().create_timer(randf_range(MIN_ANIMATION_EXTRA_TIMER_WAITING_TIME,MAX_ANIMATION_EXTRA_TIMER_WAITING_TIME)).timeout
		if can_play_idle_extra():
			play_random_idle_extra()	
	
	
func can_play_idle_extra()->bool:
	if velocity != Vector2.ZERO:
		return false
	
	
	return true
	
func play_random_idle_extra():
	is_idle_extra_playing = true
	
	var face_direction = get_face_direction()
	var effect_name := "breath"
	var anim_name = "idle" + face_direction + "_" + effect_name
	
	if animated_sprite.sprite_frames == null:
		is_idle_extra_playing = false
		return
	
	if not animated_sprite.sprite_frames.has_animation(anim_name):
	
		is_idle_extra_playing = false
		return

	animated_sprite.play(anim_name)
	await animated_sprite.animation_finished
	
	is_idle_extra_playing = false
	play_idle_animation(face_dir)
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
func _play_animation_called_by_animation_player(anim_name:String):
	if not sprite_frame.has_animation(anim_name):
		push_error(ID,"没有这个动画名: ",anim_name)
		return
	animated_sprite.play(anim_name)
	
