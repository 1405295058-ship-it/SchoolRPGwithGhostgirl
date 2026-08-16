class_name InventoryUI
extends Control

const POCKET_ID := "pocket"
const BACKPACK_ID := "backpack"

@export var inventory_slot_scene : PackedScene

@onready var pocket_grid : GridContainer = $PocketGrid

@onready var backpack_grid : GridContainer = $BackpackGrid

var has_built_slots := false

func _ready() -> void:
	connect_inventory_signals()
	build_all_bags()
	
func connect_inventory_signals() -> void:
	if not InventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		InventoryManager.inventory_changed.connect(_on_inventory_changed)
		
	if not InventoryManager.inventory_capacity_changed.is_connected(_on_inventory_capacity_changed):
		InventoryManager.inventory_capacity_changed.connect(_on_inventory_capacity_changed)
		
func build_all_bags() -> void:
	build_bag(POCKET_ID, pocket_grid)
	build_bag(BACKPACK_ID, backpack_grid)
	
	has_built_slots = true

func build_bag(bag_id : String, grid : GridContainer) -> void:
	clear_grid(grid)
	
	var capacity := InventoryManager.get_capacity(bag_id)
	
	for slot_index in range(capacity):
		var slot := create_empty_slot()
		
		if slot == null:
			continue
			
		grid.add_child(slot)
		
		slot.set_up(bag_id, slot_index)
		
func create_empty_slot() -> InventorySlot:
	if inventory_slot_scene == null:
		push_error("InventoryUI没有设置InventorySlot场景")
		return null
		
	var slot := inventory_slot_scene.instantiate() as InventorySlot
	
	if slot == null:
		push_error("Inventory场景根节点必须挂载" + "Inventoryslot脚本")
		return null
	
	return slot
		
func clear_grid(grid : GridContainer) -> void:
	for child in grid.get_children():
		child.free()
		
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
			
		
