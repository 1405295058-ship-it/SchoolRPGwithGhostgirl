class_name ItemStack
extends RefCounted

var item_data : ItemData
var amount := 0

func _init(new_item_data : ItemData, new_amount := 1) -> void:
	item_data = new_item_data
	amount = new_amount
	
##还能放多少
func get_remaining_space() -> int:
	if item_data == null:
		return 0
	
	return max(item_data.max_stack_size - amount, 0)

##判断能否堆叠
func can_stack_with(other_item : ItemData) -> bool:
	if item_data == null or other_item == null:
		return false
		
	return item_data.item_id == other_item.item_id
	
##复制堆叠数据
func duplicate_stack() -> ItemStack:
	return ItemStack.new(item_data, amount)
