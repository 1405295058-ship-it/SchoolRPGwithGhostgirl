extends Node

var cloth_bag_max_block = 2
var bag_bag_max_block = 5
var cloth_bag_things:Array = []
var bag_bag_things:Array = []

func add_item_to_bag(item_data:Need_pick_Item , amount:int):
	var left_amount = amount 
	
	#先在已经有的格子里面添加
	left_amount = add_to_existing_slot(item_data,left_amount)
	
	if left_amount ==0 :
		return left_amount
	
	left_amount = add_to_new_slot(item_data,left_amount)
	
	return left_amount		

func add_to_existing_slot(item_data:Need_pick_Item ,amount:int) -> int:
	var left_amount = amount
	for item in cloth_bag_things:
		if item["item_id"] == item_data.item_id:
			var exist_amount = item["amount"]
			if exist_amount <item_data.max_stack_size:
				var can_add = item_data.max_stack_size - exist_amount
				var amount_in = min(can_add,amount)
				left_amount -=  amount_in
				item["amount"] = exist_amount + amount_in
	for item in bag_bag_things:
		if item["item_id"] == item_data.item_id:			
			var exist_amount = item["amount"]
			if exist_amount <item_data.max_stack_size:
				var can_add = item_data.max_stack_size - exist_amount
				var amount_in = min(can_add,amount)
				left_amount -=  amount_in
				item["amount"] = exist_amount + amount_in
	return left_amount	
func add_to_new_slot(item_data:Need_pick_Item ,left_amount:int):
	var max_stack_size = item_data.max_stack_size
	while cloth_bag_things.size() < cloth_bag_max_block and left_amount>0:
		var amount_in = min(max_stack_size,left_amount)
		
		var item_infor_in = {
			"item_id": item_data.item_id,
			"amount":amount_in
		}
		cloth_bag_things.append(item_infor_in)
		left_amount -= amount_in
	
	while bag_bag_things.size() < bag_bag_max_block and left_amount>0:
		var amount_in = min(max_stack_size,left_amount)
		var item_infor_in = {
		"item_id": item_data.item_id,
		"amount":amount_in
	}
		bag_bag_things.append(item_infor_in)
		left_amount -= amount_in
	return left_amount
