class_name DropZone
extends PanelContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	if data.get("drag_type", "") != "inventory_item":
		return false

	if not data.has("bag_id"):
		return false

	if not data.has("slot_index"):
		return false

	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var bag_id: String = str(data["bag_id"])
	var slot_index: int = int(data["slot_index"])

	var stack: ItemStack = InventoryManager.get_itemstack(
		bag_id, slot_index
	)

	if stack == null:
		return

	var player := get_tree().get_first_node_in_group("player") as Player

	if player == null:
		push_error("DropZone 找不到 Player")
		return

	InventoryDropManager.drop_stack_to_world(
		bag_id,
		slot_index,
		player
	)
