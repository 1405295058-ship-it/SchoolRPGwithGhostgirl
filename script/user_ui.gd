extends CanvasLayer
var current_layer = null
var can_close_ui = false
var current_show_objectives = []
@onready var sub_mission_button_path =preload("res://tscn的文件/sub_mission.tscn")


@onready var layer_map = {
   "bag" : {
		"it_self" : $BackGround/CharacterBagLine,
		"switcher":$HBoxContainer/Bag
		},
	"mission":{
		"it_self" :$BackGround/MissionBagLine ,
		"switcher":$HBoxContainer/Mission
		},
	
}


func _ready() -> void:
	$BackGround/MissionBagLine/MainMissionTitle/MissionTitleButton.pressed.connect(func(): _is_presse_title_buttom($BackGround/MissionBagLine/MainMissionTitle/MissionTitleButton.text))
	$BackGround/MissionBagLine/MainMissionTitle2/MissionTitleButton2.pressed.connect(func(): _is_presse_title_buttom($BackGround/MissionBagLine/MainMissionTitle2/MissionTitleButton2.text))
	process_mode  = Node.PROCESS_MODE_ALWAYS
	hide()
	$BackGround/CharacterBagLine/OpenedBag.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("call_user_UI"):
		if visible:
			close_user_UI()
		else:
			show_user_UI()
	
func _on_open_bag_buttom_pressed() -> void:
	$BackGround/CharacterBagLine/OpenedBag.show()
#关掉UI

func close_user_UI():
	$BackGround/CharacterBagLine/OpenedBag.hide()
	get_tree().paused = false
	hide()
	can_close_ui = false

func show_user_UI():
	$AnimationPlayer.play("show_user_UI")
	get_tree().paused = true
	show()

	for layer in layer_map:
		layer_map[layer]["it_self"].hide()
		layer_map[layer]["switcher"].z_index=-1
	current_layer = layer_map["bag"]["it_self"]
	layer_map["bag"]["switcher"].z_index =1
	current_layer.show()
	can_close_ui = false
	await get_tree().process_frame
	can_close_ui = true

func _on_switch_to_bag_button_pressed() -> void:
	for layer in layer_map:
		layer_map[layer]["it_self"].hide()
		layer_map[layer]["switcher"].z_index=-1
	current_layer = layer_map["bag"]["it_self"]
	layer_map["bag"]["switcher"].z_index =1
	current_layer.show()
	
func _on_switch_to_mission_button_pressed() -> void:
	for layer in layer_map:
		layer_map[layer]["it_self"].hide()
		layer_map[layer]["switcher"].z_index=-1
	current_layer = layer_map["mission"]["it_self"]
	layer_map["mission"]["switcher"].z_index =1
	current_layer.show()
	get_mission_information()
	
func get_mission_information():
	var main_index = 0
	var sub_index = 0
	# 先全部隐藏/清空，避免上一次残留
	$BackGround/MissionBagLine/MainMissionTitle.hide()
	$BackGround/MissionBagLine/MainMissionTitle2.hide()
	$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = ""
	for i in $BackGround/MissionBagLine/SubMission/VBoxContainer.get_children():
		i.queue_free()
	
	for quest_name in QuestManager.available_quest:
		if QuestManager.quest_data[quest_name]["type"] == "main":
			var quest_infor = QuestManager.quest_data[quest_name]
			var current_quest_state_index = QuestManager.quest_progress[quest_name]["current_state"]
			var current_quest_state_string = str(current_quest_state_index)
			
			if main_index == 0:
				$BackGround/MissionBagLine/MainMissionTitle.show()
				$BackGround/MissionBagLine/MainMissionTitle/MissionTitleButton.text = quest_name
				$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = quest_infor["quest_states"][current_quest_state_string]["quest_description"]
				show_objectives(quest_name)
			elif main_index == 1:
				$BackGround/MissionBagLine/MainMissionTitle2.show()
				$BackGround/MissionBagLine/MainMissionTitle2/MissionTitleButton2.text = quest_name
				
			
			main_index += 1
			
			# 如果最多只显示两个主线，就直接停
			if main_index >= 2:
				break
	for quest_name in QuestManager.available_quest:
		if QuestManager.quest_data[quest_name]["type"] == "sub":
			creat_sub_mission_title(quest_name)
			
func creat_sub_mission_title(quest_name):
	print("生成支线中")
	var title = sub_mission_button_path.instantiate()
	title.get_node("MissionTitleButton2").text = quest_name
	title.get_node("MissionTitleButton2").pressed.connect(func(): _is_presse_title_buttom(quest_name))
	$BackGround/MissionBagLine/SubMission/VBoxContainer.add_child(title)

func _is_presse_title_buttom(quest_name):
		var discription = QuestManager.find_quest_discription_by_quest_name(quest_name)
		show_objectives(quest_name)
		$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = ""
		$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = discription
		
func show_objectives(quest_name):
	current_show_objectives = QuestManager.find_objectives_by_quest_name(quest_name)
	print(current_show_objectives)

	var obj1 = $BackGround/MissionBagLine/Objective/VBoxContainer/Objective1
	var obj2 = $BackGround/MissionBagLine/Objective/VBoxContainer/Objective2
	var obj3 = $BackGround/MissionBagLine/Objective/VBoxContainer/Objective3

	obj1.hide()
	obj2.hide()
	obj3.hide()

	var index = 0
	for objective in current_show_objectives:
		if index == 0:
			obj1.text = objective["text"]
			obj1.show()
		elif index == 1:
			obj2.text = objective["text"]
			obj2.show()
		elif index == 2:
			obj3.text = objective["text"]
			obj3.show()
		index += 1
