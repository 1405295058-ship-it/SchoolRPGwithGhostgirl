extends CanvasLayer
var current_layer = null
var can_close_ui = false
var current_show_objectives = []
@onready var sub_mission_button_path =preload("res://sence/需要path的/sub_mission.tscn")
@onready var bag_slot = preload("res://sence/需要path的/slot.tscn")
#背包的数据
var horizontal_max_slot = 8


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


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("call_user_UI"):
		if visible:
			close_user_UI()
		else:
			show_user_UI()

func close_user_UI():
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
	setup_bag()
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
func setup_bag():
	for child in $BackGround/CharacterBagLine/ClothBag.get_children():
		child.free()
	for child in $BackGround/CharacterBagLine/BagBag/HBoxContainer.get_children():
		child.free()
	for child in $BackGround/CharacterBagLine/BagBag/HBoxContainer2.get_children():
		child.free()
	var cloth_slot_number = InventoryManager.cloth_bag_max_block
	var bag_slot_number = InventoryManager.bag_bag_max_block
	if cloth_slot_number<= horizontal_max_slot:
		var index = 0
		while index < cloth_slot_number:
			var slot = bag_slot.instantiate()
			slot.get_node("TextureRect/ItemTexture").hide()
			slot.get_node("TextureRect/Amount").hide()
			$BackGround/CharacterBagLine/ClothBag.add_child(slot)
			index += 1
	else:		
		var index = 0
		while index < horizontal_max_slot:
			var slot = bag_slot.instantiate()
			slot.get_node("TextureRect/ItemTexture").hide()
			slot.get_node("TextureRect/Amount").hide()
			$BackGround/CharacterBagLine/ClothBag.add_child(slot)
			index += 1
	if bag_slot_number<= horizontal_max_slot:
		var index = 0
		while index < bag_slot_number:
			var slot = bag_slot.instantiate()
			slot.get_node("TextureRect/ItemTexture").hide()
			slot.get_node("TextureRect/Amount").hide()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer.add_child(slot)
			
			index += 1
	if bag_slot_number > horizontal_max_slot and bag_slot_number <= horizontal_max_slot*2:		
		var index = 0
		while index < 8:
			var slot = bag_slot.instantiate()
			slot.get_node("TextureRect/ItemTexture").hide()
			slot.get_node("TextureRect/Amount").hide()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer.add_child(slot)
			index += 1
		index= 0
		while index < bag_slot_number-8:
			var slot = bag_slot.instantiate()
			slot.get_node("TextureRect/ItemTexture").hide()
			slot.get_node("TextureRect/Amount").hide()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer2.add_child(slot)
			index += 1
	
	var cloth_slots = $BackGround/CharacterBagLine/ClothBag.get_children()
	var cloth_bag_things: Array = InventoryManager.cloth_bag_things
	var bag_slots1 = $BackGround/CharacterBagLine/BagBag/HBoxContainer.get_children()
	var bag_slots2 = $BackGround/CharacterBagLine/BagBag/HBoxContainer2.get_children()
	var bag_bag_things: Array = InventoryManager.bag_bag_things
	
	for i in range(cloth_bag_things.size()):
		var slot = cloth_slots[i]
		
		var slot_data = cloth_bag_things[i]
		var item_data = ItemDataBase.get_item(slot_data.get("item_id"))
		

		if item_data:
			slot.get_node("TextureRect/ItemTexture").texture = load(item_data.sprite)
			slot.get_node("TextureRect/ItemTexture").show()
			slot.get_node("TextureRect/Amount").text = str(slot_data.get("amount"))
			slot.get_node("TextureRect/Amount").show()

	for i in range(bag_bag_things.size()):
		var slot_data = bag_bag_things[i]
		var slot

		if i < horizontal_max_slot:
			slot = bag_slots1[i]
		else:
			slot = bag_slots2[i - horizontal_max_slot]

		var item_data = ItemDataBase.get_item(slot_data.get("item_id"))

		if item_data:
			slot.get_node("TextureRect/ItemTexture").texture = load(item_data.sprite)
			slot.get_node("TextureRect/ItemTexture").show()
			slot.get_node("TextureRect/Amount").text = str(slot_data.get("amount"))
			slot.get_node("TextureRect/Amount").show()
