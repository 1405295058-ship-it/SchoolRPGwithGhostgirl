extends CanvasLayer
var current_layer = null
var can_close_ui = false
var current_show_quest_name = ""
var current_show_objectives = []
signal change_the_track_quest
@onready var main_quest_button_path = preload("res://sence/需要path的/main_quest.tscn")
@onready var sub_quest_button_path =preload("res://sence/需要path的/sub_quest.tscn")
@onready var quest_objective_showing_space =preload("res://sence/需要path的/quest_objective_in_user_ui.tscn")
@onready var bag_slot = preload("res://sence/需要path的/slot.tscn")
#背包的数据
var horizontal_max_slot = 8



@onready var layer_map = {
   "bag" : {
		"it_self" : $BackGround/CharacterBagLine,
		"switcher":$HBoxContainer/Bag
		},
	"quest":{
		"it_self" :$BackGround/MissionBagLine ,
		"switcher":$HBoxContainer/Mission
		},
	
}


func _ready() -> void:
	$HBoxContainer/Mission/SwitchToQuestButton.pressed.connect(_on_switch_to_quest_button_pressed)
	$HBoxContainer/Bag/SwitchToBagButton.pressed.connect(_on_switch_to_bag_button_pressed)
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
	get_tree().paused = true
	$AnimationPlayer.play("show_user_UI")
	
	show()

	switch_bag_layer("bag")
	setup_bag()

func switch_bag_layer(layer_name:String):
	for layer in layer_map:
		layer_map[layer]["it_self"].hide()
		layer_map[layer]["switcher"].z_index=-1
	current_layer = layer_map[layer_name]["it_self"]
	layer_map[layer_name]["switcher"].z_index =1
	current_layer.show()	
	
func _on_switch_to_bag_button_pressed() -> void:
	switch_bag_layer("bag")
	
func _on_switch_to_quest_button_pressed() -> void:
	switch_bag_layer("quest")
	get_mission_information()
	refresh_objective_space()


##这一坨都是背包的quest显示功能
##这一坨都是背包的quest显示功能
##这一坨都是背包的quest显示功能

func get_mission_information():

	$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = ""
	
	#清除旧的button
	clear_mission_buttons()
	#清楚旧的button	
		
	for quest_name in QuestManager.active_quest:
		if QuestManager.quest_data[quest_name]["type"] == "main":
			create_main_mission_title(quest_name)
	for quest_name in QuestManager.active_quest:
		if QuestManager.quest_data[quest_name]["type"] == "sub":
			create_sub_mission_title(quest_name)
			
func clear_mission_buttons():
	for button in $BackGround/MissionBagLine/MainMission/MainMission/VBoxContainer.get_children():
		button.queue_free()
		
	for button in $BackGround/MissionBagLine/SubMission/VBoxContainer.get_children():
		button.queue_free()			

func create_main_mission_title(quest_name:String):
	print("生成支线中")
	var title = main_quest_button_path.instantiate()
	title.get_node("QuestTitleButton").text = quest_name
	title.get_node("QuestTitleButton").pressed.connect(func(): on_title_buttom_pressed(quest_name))
	$BackGround/MissionBagLine/MainMission/MainMission/VBoxContainer.add_child(title)		
func create_sub_mission_title(quest_name:String):
	print("生成支线中")
	var title = sub_quest_button_path.instantiate()
	title.get_node("QuestTitleButton").text = quest_name
	title.get_node("QuestTitleButton").pressed.connect(func(): on_title_buttom_pressed(quest_name))
	$BackGround/MissionBagLine/SubMission/VBoxContainer.add_child(title)
	

func on_title_buttom_pressed(quest_name):
		var discription = QuestManager.find_quest_discription_by_quest_name(quest_name)
		show_objectives(quest_name)
		$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = ""
		$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = discription
func refresh_objective_space():
	var objective_container = $BackGround/MissionBagLine/Objective/ObjectiveShowSpace/VBoxContainer
	for child in objective_container.get_children():
		child.queue_free()	
func show_objectives(quest_name):
	refresh_objective_space()
	current_show_objectives = QuestManager.find_objectives_by_quest_name(quest_name)
	current_show_quest_name = quest_name
	if current_show_objectives.size() > 0:
		for objective in current_show_objectives:
			var objective_block = quest_objective_showing_space.instantiate()
			var objective_node = objective_block.get_node("objectives")
			var objective_key = objective.get("in_code","")
			objective_node.text = objective.get("text","")
			var current_amount = QuestManager.quest_progress_data[quest_name
			]["objective_progress"].get(objective_key,0)
			var target_amount = objective.get("target_amount",1)
			if target_amount >1:
				target_amount = int(target_amount)
				current_amount = int(current_amount)
				var add_text = str(current_amount)+"/"+str(target_amount)
				objective_node.text += add_text
			$BackGround/MissionBagLine/Objective/ObjectiveShowSpace/VBoxContainer.add_child(objective_block)
		
##这一坨都是ui的quest显示功能在这里结束
##这一坨都是ui的quest显示功能在这里结束
##这一坨都是ui的quest显示功能在这里结束

##这一坨都是ui的背包显示功能在这里开始


func setup_bag():
	
	create_cloth_bag_slot()
	create_bag_bag_slot()
	fill_the_cloth_bag_slot()
	fill_the_bag_bag_slot()
	
func create_empty_slot():
	var slot = bag_slot.instantiate()
	slot.get_node("TextureRect/ItemTexture").hide()
	slot.get_node("TextureRect/Amount").hide()
	slot.get_node("Discription").hide()
	return slot
func create_cloth_bag_slot():
	for child in $BackGround/CharacterBagLine/ClothBag.get_children():
		child.free()
	var cloth_slot_number = InventoryManager.cloth_bag_max_block
	if cloth_slot_number<= horizontal_max_slot:
		var index = 0
		while index < cloth_slot_number:
			var slot = create_empty_slot()
			$BackGround/CharacterBagLine/ClothBag.add_child(slot)	
			index += 1
	else:		
		var index = 0
		while index < horizontal_max_slot:
			
			index += 1
func create_bag_bag_slot():		
	for child in $BackGround/CharacterBagLine/BagBag/HBoxContainer.get_children():
		child.free()
	for child in $BackGround/CharacterBagLine/BagBag/HBoxContainer2.get_children():
		child.free()	
	var bag_slot_number = InventoryManager.bag_bag_max_block
	if bag_slot_number<= horizontal_max_slot:
		var index = 0
		while index < bag_slot_number:
			var slot = create_empty_slot()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer.add_child(slot)
			
			index += 1
	if bag_slot_number > horizontal_max_slot and bag_slot_number <= horizontal_max_slot*2:		
		var index = 0
		while index < 8:
			var slot = create_empty_slot()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer.add_child(slot)
			index += 1
		index= 0
		while index < bag_slot_number-8:
			var slot = create_empty_slot()
			$BackGround/CharacterBagLine/BagBag/HBoxContainer2.add_child(slot)
			index += 1
func fill_the_cloth_bag_slot():
	var cloth_slots = $BackGround/CharacterBagLine/ClothBag.get_children()
	var cloth_bag_things: Array = InventoryManager.cloth_bag_things
	for i in range(cloth_bag_things.size()):
		var slot = cloth_slots[i]
		
		var slot_data = cloth_bag_things[i]
		var item_data = ItemDataBase.get_item(slot_data.get("item_id"))
		

		if item_data:
			slot.get_node("TextureRect/ItemTexture").texture = load(item_data.sprite)
			slot.get_node("TextureRect/ItemTexture").show()
			slot.get_node("TextureRect/Amount").text = str(slot_data.get("amount"))
			slot.get_node("TextureRect/Amount").show()
			slot.get_node("Discription/DiscriptionLable").text = item_data.description
func fill_the_bag_bag_slot():
	
	var bag_slots1 = $BackGround/CharacterBagLine/BagBag/HBoxContainer.get_children()
	var bag_slots2 = $BackGround/CharacterBagLine/BagBag/HBoxContainer2.get_children()
	var bag_bag_things: Array = InventoryManager.bag_bag_things
	

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
			slot.get_node("Discription/DiscriptionLable").text = item_data.description

func _on_track_quest_button_pressed() -> void:
	if current_show_quest_name == "":
		return
	
	QuestManager.set_tracking_quest(current_show_quest_name)
