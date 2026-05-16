extends Node2D

@export var item_data:Need_pick_Item
@export var item_amount = 1

func _ready() -> void:
	if item_data:
		$Sprite2D.texture = load(item_data.sprite)
	$Amount.text = str(item_amount)
func interact(player):
	QuestManager.check_event_is_quest_need("pick_up_"+item_data.item_id)
	var left_amount = InventoryManager.add_item_to_bag(item_data,item_amount)
	if left_amount>0:
		item_amount = left_amount
		$Amount.text = str(item_amount)
	elif left_amount == 0 :

		queue_free()
	else:
		print("这东西他妈变成负数了")
	
