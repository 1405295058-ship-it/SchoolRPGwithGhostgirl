class_name InventoryUI
extends Control

const POCKET_ID := "pocket"
const BACKPACK_ID := "backpack"

var current_info_bag_id : String = ""
var current_info_slot_index : int = -1

@export var inventory_slot_scene : PackedScene

@onready var item_info_panel : PanelContainer = $ItemInfoPanel
@onready var item_name_label : Label = $ItemInfoPanel/VBoxContainer/NameLabel
@onready var item_description_label : Label = $ItemInfoPanel/VBoxContainer/DescribtionLabel
@onready var drop_item_botton : Button = $ItemInfoPanel/VBoxContainer/DropButton
@onready var close_item_info_button : Button = $ItemInfoPanel/VBoxContainer/CloseButton

@onready var pocket_grid : GridContainer = $PocketGrid

@onready var backpack_grid : GridContainer = $BackpackGrid

var has_built_slots := false

func _ready() -> void:
	connect_inventory_signals()
	build_all_bags()
	item_info_panel.hide()
	
	if not close_item_info_button.pressed.is_connected(close_item_info):
		close_item_info_button.pressed.connect(close_item_info)
		
	if not drop_item_botton.pressed.is_connected(_on_drop_button_pressed):
		drop_item_botton.pressed.connect(_on_drop_button_pressed)
	
#连接inventorymanager的内容和容量变化, 在ready()调用
func connect_inventory_signals() -> void:
	if not InventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		InventoryManager.inventory_changed.connect(_on_inventory_changed)
		
	if not InventoryManager.inventory_capacity_changed.is_connected(_on_inventory_capacity_changed):
		InventoryManager.inventory_capacity_changed.connect(_on_inventory_capacity_changed)
		
#首次生成Pocket/backpack的UI slots, 在ready()调用
func build_all_bags() -> void:
	build_bag(POCKET_ID, pocket_grid)
	build_bag(BACKPACK_ID, backpack_grid)

#根据manager中的bag重建对应UI, 在build_all_bags(), refresh_bag(), _on_inventory_capacity_changed()调用
func build_bag(bag_id : String, grid : GridContainer) -> void:
	clear_grid(grid)
	
	var capacity := InventoryManager.get_capacity(bag_id)
	
	for slot_index in range(capacity):
		var slot := create_empty_slot()
		
		if slot == null:
			continue
			
		grid.add_child(slot)
		
		slot.set_up(bag_id, slot_index)

#实例化一个 InventorySlot.tscn， 在build_bag()调用
func create_empty_slot() -> InventorySlot:
	if inventory_slot_scene == null:
		push_error("InventoryUI没有设置InventorySlot场景")
		return null
		
	var slot := inventory_slot_scene.instantiate() as InventorySlot
	
	if slot == null:
		push_error("Inventory场景根节点必须挂载" + "Inventoryslot脚本")
		return null
		
	if not slot.item_info_requested.is_connected(show_item_info):
		slot.item_info_requested.connect(show_item_info)
	
	return slot
#根据传入的itemdata显示物品名称和描述, 在Inventory.item_info_requested()调用
func show_item_info(item_data: ItemData, bag_id: String, slot_index: int) -> void:
	if item_data == null:
		return

	var grid := get_grid(bag_id)

	if grid == null:
		return

	if slot_index < 0 or slot_index >= grid.get_child_count():
		return

	var slot := grid.get_child(slot_index) as Control

	if slot == null:
		return

	current_info_bag_id = bag_id
	current_info_slot_index = slot_index

	item_name_label.text = item_data.item_name
	item_description_label.text = item_data.description

	# 设置面板尺寸
	item_info_panel.show()
	

	var panel_size := item_info_panel.size
	var viewport_size := get_viewport_rect().size

	var gap := 12.0

	# 优先出现在格子右边
	var target_pos := slot.global_position + Vector2(
		slot.size.x + gap,
		0
	)

	# 右边放不下就放左边
	if target_pos.x + panel_size.x > viewport_size.x:
		target_pos.x = slot.global_position.x - panel_size.x - gap

	# 限制在屏幕范围内
	target_pos.x = clampf(
		target_pos.x,
		0,
		maxf(0, viewport_size.x - panel_size.x)
	)

	target_pos.y = clampf(
		target_pos.y,
		0,
		maxf(0, viewport_size.y - panel_size.y)
	)

	item_info_panel.global_position = target_pos

	await get_tree().process_frame

	
func _on_drop_button_pressed() -> void:
	if current_info_bag_id == "":
		return

	if current_info_slot_index < 0:
		return

	var removed_stack: ItemStack = InventoryManager.remove_stack(
		current_info_bag_id,
		current_info_slot_index
	)

	if removed_stack == null:
		close_item_info()
		return

	print("永久删除物品：", removed_stack.item_data.item_id)

	close_item_info()
#关闭物品详情窗口
func close_item_info() -> void:
	item_info_panel.hide()
	
	current_info_bag_id = ""
	current_info_slot_index = -1

#立即删除grid中存在的UI slot, 在build_bag()调用		
func clear_grid(grid : GridContainer) -> void:
	for child in grid.get_children():
		child.free()

#刷新所有背包UI, 在UserUI.show_user_UI()调用
func refresh_all() -> void:
	refresh_bag(POCKET_ID)
	refresh_bag(BACKPACK_ID)
	
	
func refresh_bag(bag_id : String) -> void:
	var grid := get_grid(bag_id)
	
	if grid == null:
		return
		
	var children := grid.get_children()
	var capacity := InventoryManager.get_capacity(bag_id)
	
	if children.size() != capacity:
		build_bag(bag_id, grid)
		return
	
	for child in children:
		var slot := child as InventorySlot
		
		if slot != null:
			slot.refresh()

func _on_inventory_changed(bag_id : String) -> void:
	refresh_bag(bag_id)
	
func _on_inventory_capacity_changed(bag_id : String) -> void:
	var grid := get_grid(bag_id)
	
	if grid == null:
		return
		
	build_bag(bag_id, grid)
	
func get_grid(bag_id : String) -> GridContainer:
	match bag_id:
		POCKET_ID:
			return pocket_grid
		
		BACKPACK_ID:
			return backpack_grid
			
		_:
			push_error("InventoryUI 不认识这个背包" + bag_id)
			return null
			
		
