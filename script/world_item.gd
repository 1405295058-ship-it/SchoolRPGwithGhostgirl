@tool
class_name WorldItem
extends Area2D

@export var item_data: ItemData :
	set(value):
		item_data = value
		
		if is_inside_tree():
			call_deferred("update_item_visual")

@export_range(1,9999,1)
var amount : int = 1

@onready var item_sprite : Sprite2D = $ItemSprite

var is_picking_up : bool = false

#============================= lifecycle=======================


func _ready() -> void:
	update_item_visual()
	
#根据item_data.icon更新Itemsprite, 在_ready()调用
func update_item_visual() -> void:
	var sprite := get_node_or_null("ItemSprite") as Sprite2D
	
	if sprite == null:
		push_warning("找不到sprite2D")
		return

	if item_data == null:
		item_sprite.texture = null
		return
		
	if item_data.icon == null:
		sprite.texture = null
		push_warning("道具 %s 没有设置icon" % item_data.item_name)
		return
		
	item_sprite.texture = item_data.icon
	sprite.z_index = 10
	
	#======================== player interaction ======================
	

func interact(_player) -> void:
	pick_up()
	
	
#============================= pickup ========================


#把worlditem放进inventorymanager, 在interact()调用
func pick_up() -> void:
	if is_picking_up:
		return
		
	if item_data == null:
		push_error("WorldItem 没有设置：" + name)
		return
		
	if amount <= 0:
		queue_free()
		return
		
	is_picking_up = true
	
	var original_amount : int = amount
	
	var result : Dictionary = InventoryManager.add_item(item_data, original_amount)
	print("Manager 原始返回值：", result)
	
	var added_amount : int = int(result["added_amount"])
	
	var remaining_amount : int = int(result["remaining_amount"])
	
	print("拾取结果: 请求=", original_amount, "，成功=", added_amount, "，剩余=", remaining_amount)
	
	if added_amount <= 0:
		is_picking_up = false
		show_inventory_full_message()
		return
		
	QuestManager.check_event_is_quest_need("pick_up_" + item_data.item_id, added_amount)
	
	amount = remaining_amount
	
	if amount <= 0:
		monitoring = false
		monitorable = false
		
		queue_free()
		return
		
	update_remaining_item()
	
	is_picking_up = false

func update_remaining_item() -> void:
	print("部分拾取成功， 地上还剩:", amount, "个", item_data.item_id)
	
func show_inventory_full_message() -> void:
	print("背包空间不足，无法拾取：", item_data.item_id)


		
