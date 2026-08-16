extends CanvasLayer


var current_layer: Control = null
var can_close_ui: bool = false

var current_show_quest_name: String = ""
var current_show_objectives: Array = []


@onready var inventory_ui: InventoryUI = $BackGround/CharacterBagLine/InventoryUI


@onready var main_quest_button_path: PackedScene = preload("res://sence/需要path的/main_quest.tscn")

@onready var sub_quest_button_path: PackedScene = preload("res://sence/需要path的/sub_quest.tscn")

@onready var quest_objective_showing_space: PackedScene = preload("res://sence/需要path的/quest_objective_in_user_ui.tscn")

@onready var layer_map: Dictionary = {
	"bag": {
		"it_self": $BackGround/CharacterBagLine,
		"switcher": $HBoxContainer/Bag
	},
	"quest": {
		"it_self": $BackGround/MissionBagLine,
		"switcher": $HBoxContainer/Mission
	}
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	$HBoxContainer/Mission/SwitchToQuestButton.pressed.connect(_on_switch_to_quest_button_pressed)

	$HBoxContainer/Bag/SwitchToBagButton.pressed.connect(_on_switch_to_bag_button_pressed)

	hide()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("call_user_UI"):
		if visible:
			close_user_UI()
		else:
			show_user_UI()


func close_user_UI() -> void:
	get_tree().paused = false

	hide()
	can_close_ui = false


func show_user_UI() -> void:
	get_tree().paused = true

	$AnimationPlayer.play("show_user_UI")
	$AnimationPlayer.seek(0.0, true)

	show()

	switch_bag_layer("bag")

	if inventory_ui != null:
		inventory_ui.refresh_all()


func switch_bag_layer(layer_name: String) -> void:
	if not layer_map.has(layer_name):
		push_error("不存在这个 UI 页面：" + layer_name)
		return

	for each_layer in layer_map:
		var layer_data: Dictionary = layer_map[each_layer]

		var layer_control := layer_data["it_self"] as Control
		var switcher_control := layer_data["switcher"] as Control

		layer_control.hide()
		switcher_control.z_index = -1

	current_layer = layer_map[layer_name]["it_self"] as Control

	var current_switcher := layer_map[layer_name]["switcher"] as Control

	current_switcher.z_index = 1
	current_layer.show()


func _on_switch_to_bag_button_pressed() -> void:
	switch_bag_layer("bag")

	if inventory_ui != null:
		inventory_ui.refresh_all()


func _on_switch_to_quest_button_pressed() -> void:
	switch_bag_layer("quest")

	get_mission_information()
	refresh_objective_space()



func get_mission_information() -> void:
	$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = ""

	clear_mission_buttons()

	for quest_name in QuestManager.active_quest:
		if QuestManager.quest_data[quest_name]["type"] == "main":
			create_main_mission_title(quest_name)

	for quest_name in QuestManager.active_quest:
		if QuestManager.quest_data[quest_name]["type"] == "sub":
			create_sub_mission_title(quest_name)


func clear_mission_buttons() -> void:
	var main_container := $BackGround/MissionBagLine/MainMission/MainMission/VBoxContainer

	for button in main_container.get_children():
		button.queue_free()

	var sub_container := $BackGround/MissionBagLine/SubMission/VBoxContainer

	for button in sub_container.get_children():
		button.queue_free()


func create_main_mission_title(quest_name: String) -> void:
	var title := main_quest_button_path.instantiate()

	var title_button := title.get_node(
		"QuestTitleButton"
	) as Button

	title_button.text = quest_name

	title_button.pressed.connect(
		func() -> void:
			on_title_button_pressed(quest_name)
	)

	$BackGround/MissionBagLine/MainMission/MainMission/VBoxContainer.add_child(
		title
	)


func create_sub_mission_title(quest_name: String) -> void:
	var title := sub_quest_button_path.instantiate()

	var title_button := title.get_node(
		"QuestTitleButton"
	) as Button

	title_button.text = quest_name

	title_button.pressed.connect(
		func() -> void:
			on_title_button_pressed(quest_name)
	)

	$BackGround/MissionBagLine/SubMission/VBoxContainer.add_child(
		title
	)


func on_title_button_pressed(quest_name: String) -> void:
	var description: String = QuestManager.find_quest_discription_by_quest_name(quest_name)

	show_objectives(quest_name)

	$BackGround/MissionBagLine/Discription/DiscriptionPlace.text = description


func refresh_objective_space() -> void:
	var objective_container := $BackGround/MissionBagLine/Objective/ObjectiveShowSpace/VBoxContainer

	for child in objective_container.get_children():
		child.queue_free()


func show_objectives(quest_name: String) -> void:
	refresh_objective_space()

	current_show_objectives = QuestManager.find_objectives_by_quest_name(quest_name)

	current_show_quest_name = quest_name

	if current_show_objectives.is_empty():
		return

	for objective in current_show_objectives:
		var objective_block := quest_objective_showing_space.instantiate()

		var objective_node := objective_block.get_node("objectives") as Label

		var objective_key: String = objective.get(
			"in_code",
			""
		)

		objective_node.text = objective.get(
			"text",
			""
		)

		var current_amount = QuestManager.quest_progress_data[quest_name]["objective_progress"].get(
				objective_key,
				0
			)

		var target_amount = objective.get(
			"target_amount",
			1
		)

		if target_amount > 1:
			target_amount = int(target_amount)
			current_amount = int(current_amount)

			var amount_text := "%d/%d" % [
				current_amount,
				target_amount
			]

			objective_node.text += " " + amount_text

		$BackGround/MissionBagLine/Objective/ObjectiveShowSpace/VBoxContainer.add_child(
			objective_block
		)


func _on_track_quest_button_pressed() -> void:
	if current_show_quest_name == "":
		return

	EventBus.set_tracking_quest.emit(
		current_show_quest_name
	)
