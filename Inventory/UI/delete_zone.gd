class_name DeleteZone
extends PanelContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	print("拖拽检查")
	if not data is Dictionary:
		return false
		
	if data.get("drag_type", "") != "inventory_item":
		return false
		
	if not data.has("bag_id"):
		return false
		
	if not data.has("slot_index"):
		return false
		
	print("允许删掉")
		
	return true
	
func _drop_data(_at_position : Vector2, data : Variant) -> void:
	var bag_id : String = str(data["bag_id"])
	var slot_index : int = int(data["slot_index"])
	
	var stack : ItemStack = InventoryManager.get_itemstack(bag_id, slot_index)
	
	if stack == null:
		print("已经空了")
		return
	
	print("准备删除")
	
	var removed_stack : ItemStack = InventoryManager.remove_stack(bag_id, slot_index)
		
	print("永久删除物品：", removed_stack.item_data.item_id, " × ", removed_stack.amount)
	
