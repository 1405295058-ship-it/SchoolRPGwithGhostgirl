extends Node

const POCKET_ID := "pocket"
const BACKPACK_ID := "backpack"

var bags : Dictionary = {}


#====================== signals ====================


#背包内数据发生变化时发出
signal inventory_changed(bag_id : String)

#背包容量发生变化时发出
signal inventory_capacity_changed(bag_id : String)

#==================== initialization ========================


func _ready() -> void:
	initialize_inventory()
	

func initialize_inventory() -> void:
	if not bags.is_empty():
		return
	
	create_bag(POCKET_ID,2)
	create_bag(BACKPACK_ID,5)
	
#创建背包, 在initialize_inventory()调用
func create_bag(bag_id : String, capacity : int) -> void:
	if bags.has(bag_id):
		push_warning("背包已存在：" + bag_id)
		return
	
	if capacity < 0:
		push_error("背包容量不能小于0")
		return
	
	var slots : Array = []
	
	for i in range(capacity):
		slots.append(null)
	
	bags[bag_id] = slots	
	
	
#=========================== read data ========================
	
	
#获取指定背包容量, 在InventoryUI.build_bag(), Inventory.refresh_bag()调用
func get_capacity(bag_id : String) -> int:
	if not bags.has(bag_id):
		push_error("不存在这个背包：" + bag_id)
		return 0
		
	var slots : Array = bags[bag_id]
	return slots.size()
	
#获取格子中ItemStack	, 在InventorySlot.refresh(), InventorySlot._get_drag_data()调用
func get_itemstack(bag_id : String, slot_index : int) -> ItemStack:
	if not is_valid_slot(bag_id,slot_index):
		return null
	
	return bags[bag_id][slot_index] as ItemStack
	
#获取格子中Itemdata, 游戏逻辑查询物品类型时可以调用
func get_item_data(bag_id : String, slot_index : int) -> ItemData:
	var stack := get_itemstack(bag_id, slot_index)
	
	if stack == null:
		return null
				
	return stack.item_data

#检查容器和格子下标合不合理, manager中所有读写slot的函数
func is_valid_slot(bag_id : String, slot_index : int) -> bool:
	if not bags.has(bag_id):
		push_error("不存在此背包：" + bag_id)
		return false
		
	var slots : Array = bags[bag_id]
	if slot_index < 0 or slot_index >= slots.size():
		push_error("格子下标超出范围，容器：%s, 下标：%d" % [bag_id, slot_index])
		return false
		
	return true


#======================== add item ====================


#加入道具到背包, 在worlditem.pickup()调用
func add_item(item : ItemData, amount : int = 1) -> Dictionary:
	var result = {
		##原本想加入多少
		"requested_amount" : amount,
		##实际加入多少
		"added_amount" : 0,
		##没有放进去多少
		"remaining_amount" : amount,
		##是否全部放入
		"success" : false
	}
	
	if item == null:
		push_error("空物品无法加入")
		return result
		
	if amount <= 0:
		push_warning("添加物品需要大于0")
		return result
		
	var remaining_amount := amount
	remaining_amount = add_to_existing_stacks(POCKET_ID,item,remaining_amount)
	
	remaining_amount = add_to_existing_stacks(BACKPACK_ID,item,remaining_amount)
	
	remaining_amount = add_to_empty_slots(POCKET_ID,item,remaining_amount)
	
	remaining_amount = add_to_empty_slots(BACKPACK_ID,item,remaining_amount)
	
	result["added_amount"] = amount - remaining_amount
	result["remaining_amount"] = remaining_amount
	result["success"] = remaining_amount == 0
	return result
	
#把物品加入已有同类堆叠, 在add_item()调用
func add_to_existing_stacks(bag_id : String, item : ItemData, amount : int) -> int:
	if amount <= 0:
		push_warning("添加物品需要大于0")
		return 0
		
	if not bags.has(bag_id):
		push_error("背包不存在:" + bag_id)
		return amount
		
	var slots : Array = bags[bag_id]
	var remaining_amount = amount
	var bag_change = false
	
	for slot_index in range(slots.size()):
		var stack = slots[slot_index] as ItemStack
				
		if stack == null:
			continue
			
		if not stack.can_stack_with(item):
			continue
				
		var available_space := stack.get_remaining_space()
			
		if available_space <= 0:
				continue
				
		var added_amount : Variant = min(available_space, remaining_amount)
		stack.amount += added_amount
		remaining_amount -= added_amount
		bag_change = true
			
		if remaining_amount <= 0:
			break
				
	if bag_change:
		inventory_changed.emit(bag_id)
				
	return remaining_amount
	
#把剩余数量分配进空格子, 在add_item()调用
func add_to_empty_slots(bag_id : String, item : ItemData, amount : int) -> int:
	if amount <= 0:
		return 0
		
	if not bags.has(bag_id):
		push_error("背包不存在：", bag_id)
		return amount
	var slots : Array = bags[bag_id]
	var remaining_amount = amount
	var bag_changed = false
	
	for slot_index in range(slots.size()):
		if slots[slot_index] != null:
			continue
			
		var stack_amount : Variant = min(item.max_stack_size, remaining_amount)
		
		slots[slot_index] = ItemStack.new(item, stack_amount)
		
		remaining_amount -= stack_amount
		
		bag_changed = true
		
		if remaining_amount <= 0:
			break
	
	if bag_changed:
		inventory_changed.emit(bag_id)
		
	return remaining_amount


#======================== drag/ move/ swap ==================


#实现背包拖拽规则, 在InventorySlot._drop_data()调用
func move_or_swap_stack(from_bag_id : String, from_slot_index : int, to_bag_id : String, to_slot_index: int) -> void:
	if not is_valid_slot(from_bag_id, from_slot_index):
		return
		
	if not is_valid_slot(to_bag_id, to_slot_index):
		return
		
	if(from_bag_id == to_bag_id and from_slot_index == to_slot_index):
		return
		
	var from_stack = get_itemstack(from_bag_id, from_slot_index)
	var to_stack = get_itemstack(to_bag_id, to_slot_index)
	
	if from_stack == null:
		return
		
	if to_stack == null:
		bags[to_bag_id][to_slot_index] = from_stack
		bags[from_bag_id][from_slot_index] = null
		
		emit_changed_for_bags(from_bag_id, to_bag_id)
		return
		
	swap_stack(from_bag_id, from_slot_index, to_bag_id, to_slot_index)

#强制交换两个格子的堆叠, 在move_or_swap_stack()调用
func swap_stack(from_bag_id : String, from_slot_index : int, to_bag_id : String, to_slot_index: int) -> void:
	if not is_valid_slot(from_bag_id, from_slot_index):
		return
		
	if not is_valid_slot(to_bag_id, to_slot_index):
		return
	
	var from_stack = get_itemstack(from_bag_id, from_slot_index)
	var to_stack = get_itemstack(to_bag_id, to_slot_index)
	
	bags[from_bag_id][from_slot_index] = (to_stack)
	bags[to_bag_id][to_slot_index] = (from_stack)
	
	emit_changed_for_bags(from_bag_id, to_bag_id)

#修改bag数据后发送刷新信号, 在move_or_swap_stack(), swap_stack()调用
func emit_changed_for_bags(first_bag_id : String, second_bag_id : String) -> void:
	inventory_changed.emit(first_bag_id)
	
	if first_bag_id != second_bag_id:
		inventory_changed.emit(second_bag_id)
	
	
#==================== remove ==========================

		
##删除和减少数量, 在消耗品任务交付等系统调用
func remove_amount(bag_id : String, slot_index : int, amount: int) -> int:
	if not is_valid_slot(bag_id, slot_index):
		return 0
		
	if amount <= 0:
		return 0
		
	var stack = get_itemstack(bag_id, slot_index)
	
	if stack == null:
		return 0
		
	var remove_amount : Variant = min(stack.amount, amount)
	
	stack.amount -= remove_amount
	
	if stack.amount <= 0:
		bags[bag_id][slot_index] = null

	inventory_changed.emit(bag_id)
	
	return remove_amount

##删除整个格子内容, 在丢弃物品，移动到其它系统时调用
func remove_stack(bag_id : String, slot_index : int) -> ItemStack:
	if not is_valid_slot(bag_id, slot_index):
		return null
		
	var remove_stack = get_itemstack(bag_id, slot_index)
	
	bags[bag_id][slot_index] = null
	
	inventory_changed.emit(bag_id)
	
	return remove_stack
	
	
#===================== capacity ==========================
	
	
##扩容背包, 在后续背包升级时调用
func expand_bag(bag_id : String, additional_capacity : int) -> void:
	if not bags.has(bag_id):
		push_error("背包不存在：" + bag_id)
		return
	
	if additional_capacity <= 0:
		push_warning("扩容数量要大于0")
		return
		
	var slots : Array = bags[bag_id]
	
	for i in range(additional_capacity):
		slots.append(null)
		
		inventory_capacity_changed.emit(bag_id)
		inventory_changed.emit(bag_id)
	
	
#===================== query ======================
	
	
##判断还存不存在放入道具的位置, 在其它系统判断时调用
func has_empty_slot() -> bool:
	for bag_id in bags:
		var slots : Array = bags[bag_id]
		
		for stack in slots:
			if stack == null:
				return true
				
	return false
	
#检查背包是否有指定数量的某个物品
func check_item(item_id: String, required_amount: int = 1) -> bool:
	if item_id == "":
		return false

	if required_amount <= 0:
		return true

	var total_amount: int = 0

	for bag_id in bags:
		var slots: Array = bags[bag_id]

		for value in slots:
			var stack := value as ItemStack

			if stack == null:
				continue

			if stack.item_data == null:
				continue

			if stack.item_data.item_id != item_id:
				continue

			total_amount += stack.amount

			if total_amount >= required_amount:
				return true

	return false
	
##判断道具还能不能至少放入一个, world，UI判断背包空间时调用
func can_add_item(item : ItemData) -> bool:
	if item == null:
		return false
		
	for bag_id in bags:
		var slots : Array = bags[bag_id]
		
		for value in slots:
			var stack := value as ItemStack
			
			if stack == null:
				return true
		
			if (stack.can_stack_with(item) and stack.amount < item.max_stack_size):
				return true
	
	return false
		
	
