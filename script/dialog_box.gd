extends CanvasLayer

var player_face_map = {
	"normal" : "res://art/face/主角_说话.png"
	
}

var dialog_list = []
var options = []
var dialogs = []
var current = 0

var current_face_map = {}

@onready var content = $Content
@onready var head = $Content/head
@onready var NextI = $Content/Nextindicator

var interval = 0.5
var tween: Tween

var is_in_dialog = false
var just_closed = false

func _ready():
	$Content/Options/option1.pressed.connect(func(): _on_option_pressed(0))
	$Content/Options/option2.pressed.connect(func(): _on_option_pressed(1))
	$Content/Options/option3.pressed.connect(func(): _on_option_pressed(2))
	hide_DialogBox()
	hide_options()
	
	
	
func _process(delta):
	player_input()
	
func player_input():
	if Input.is_action_just_pressed("Interaction") and $Content.visible:
		if tween and tween.is_running():
			tween.kill()
			$Content/dialog.visible_ratio = 1
			NextI.show()
			
		
		
		elif current +1 < dialogs.size():
			current += 1
			process_dialog(current)
			
		else: 
			if options.is_empty() :
				await close_dialog()
			else:
				show_options()
		


	
func hide_DialogBox():
	$Content.hide()

func start_dialog(current_dialog_list,face_map,defult_dialog):
	print("start dialog")
	$AnimationPlayer.play("dialog_show_cg")
	show()
	$Content.show()
	
	get_tree().paused = true
	is_in_dialog = true
	current = 0
	current_face_map = face_map
	if current_dialog_list.is_empty():
		dialogs = defult_dialog
		process_dialog(current)
	else:
		dialog_list = current_dialog_list
		
		for state in dialog_list:
			if state["talk_state"] == "start":
				dialogs = state["dialog"]
				options = state["options"]
				process_dialog(current)
	current = 0

	
			
			
			
func process_dialog(index):
	if dialogs != null:			
		$Content/dialog.text = dialogs[index]["text"]
		var emotion = dialogs[index]["emotion"]
		var head_path = current_face_map[emotion]
		head.texture = load(head_path)
		$Content/dialog.visible_ratio = 0
		NextI.hide()
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property($Content/dialog, "visible_ratio", 1.0, 0.5)
		await tween.finished
		NextI.show()
					
func player_option():
	pass
			
func close_dialog():
	
	hide_DialogBox()
	hide_options()
	is_in_dialog = false

	get_tree().paused = false

	just_closed = true
	await get_tree().create_timer(0.15, true, false, true).timeout
	just_closed = false
	print("just_closed reset")

	
	
			
	
	
#这是角色选项
func show_options():
	$Content/dialog.text = ""
	if options.is_empty() :
		return
	$Content.text = ""
	$Content/Options.show()
	$Content/Options/option1.hide()
	$Content/Options/option2.hide()
	$Content/Options/option3.hide()
	var emotion = "normal"
	var index = 0
	$Content/head.texture = load(player_face_map[emotion])
	for i in options:
		if index == 0:
			$Content/Options/option1.show()
			$Content/Options/option1.text = i["text"]
		if index == 1:
			$Content/Options/option2.show()
			$Content/Options/option2.text = i["text"]
		if index == 2:
			$Content/Options/option3.show()
			$Content/Options/option3.text = i["text"]
		index += 1
	
func _on_option_pressed(index):
	if options.is_empty() :
		return
	hide_options()
	var next_state = options[index]["next"]
	current = 0
	for state in dialog_list:
		if state["talk_state"] == next_state:
			dialogs = state["dialog"]
			options = state["options"]
			await process_dialog(current)
			break

func hide_options():
	$Content/Options.hide()	

	
