extends CanvasLayer

var player_face_map = {
	"normal" : "res://art/face/主角_说话.png"
	
}

var next_player_step = ""
var dialog_list = []
var options = []
var dialogs = []
var current = 0
var next_state = ""

var current_face_map = {}

@onready var content = $Content
@onready var head = $Content/head
@onready var NextI = $Content/Nextindicator

var interval = 0.5
var tween: Tween

var is_in_dialog = false
var just_closed = false

var player_name = ""

func _ready():
	$Content/Options/option1.pressed.connect(func(): _on_option_pressed(0))
	$Content/Options/option2.pressed.connect(func(): _on_option_pressed(1))
	$Content/Options/option3.pressed.connect(func(): _on_option_pressed(2))
	hide_DialogBox()
	hide_options()
	hide_naming()
	
	
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
			match next_player_step:
				"options":
					show_options()
				"naming":
					player_naming_show()
				"end":
					await close_dialog()



	
func hide_DialogBox():
	$Content.hide()

func start_dialog(current_dialog_list,face_map,defult_dialog):
	next_player_step = ""
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
		next_player_step = "end"
	else:
		dialog_list = current_dialog_list
		
		for state in dialog_list:
			if state["talk_state"] == "start":
				dialogs = state["dialog"]#这里是判断下一个交互是取名字吗 还是干嘛
				options = []
				if state.has("options"):
					options = state["options"]
					next_player_step = "options"
				elif state.has("naming"):
					next_player_step = "naming"
					next_state = state["naming"]["next"]
				elif state.has("end"):
					next_player_step = "end"
				else:
					print("你的对话数据option那一栏的状态是不是打错了boy")
				
			
				
				process_dialog(current)
	current = 0


			
			
			
func process_dialog(index):
	if dialogs != null:
		var dialog_text = dialogs[index]["text"]	
		
		
		
		dialog_text = dialog_text.replace("{player}", player_name)	
		
		
		
		
		$Content/dialog.text = dialog_text
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
					

			
func close_dialog():
	
	hide_DialogBox()
	hide_options()
	is_in_dialog = false

	get_tree().paused = false

	just_closed = true
	await get_tree().create_timer(0.15, true, false, true).timeout
	just_closed = false
	print("just_closed reset")

	
func hide_naming():
	$Content/Naming.hide()
func player_naming_show():
	$Content/Naming.show()
	$Content/dialog.text = ""
	$Content/Naming/Warning.text = ""
	$Content/Naming/LineEdit.text = ""		
	$Content/Nextindicator.hide()
	
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
	next_state = options[index]["next"]
	current = 0
	go_to_next_state()

func hide_options():
	$Content/Options.hide()	

func go_to_next_state():
	for state in dialog_list:
		if state["talk_state"] == next_state:
			dialogs = state["dialog"]
			options = []
			next_player_step = ""
			if state.has("options"):
				options = state["options"]
				next_player_step = "options"
			elif state.has("naming"):
				next_player_step = "naming"
				next_state = state["naming"]["next"]
			elif state.has("end"):
				next_player_step = "end"
			else:
				print("你的对话数据option那一栏的状态是不是打错了boy")
			await process_dialog(current)
			break	


func _on_sure_button_pressed() -> void:
	var player_name_check = $Content/Naming/LineEdit.text
	if player_name_check.strip_edges().length() == 0:
		$Content/Naming/Warning.text = "不是哥们儿 你没名字吗？"
	elif player_name_check.length() >10 :
		$Content/Naming/Warning.text = "不是哥们儿 你名字太长了吧"
	else:
		player_name = player_name_check.strip_edges()
		current = 0
		hide_naming()

		go_to_next_state()
