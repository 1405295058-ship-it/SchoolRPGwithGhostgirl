extends Node

var world_item_scene: PackedScene = preload("res://sence/tscn的文件/world_item.tscn")

func drop_stack_to_world(bag_id : String, slot_index : int, player : Player) -> void:
	if player == null:
		return
		
	var stack: ItemStack = InventoryManager.remove_stack(bag_id, slot_index)
	
	if stack == null:
		return
		
	if stack.item_data == null:
		return
		
	var world_item := world_item_scene.instantiate() as WorldItem
	
	if world_item == null:
		push_error("WorldItem Scene根节点必须用WorldItem.gd")
		return
		
	world_item.item_data = stack.item_data
	world_item.amount = stack.amount
	
	player.get_parent().add_child(world_item)
	
	world_item.global_position = player.global_position + player.face_dir*50
