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

##是否自动拾取
##false 表示交互拾取

@export var auto_pick : bool = false

@onready var item_sprite : Sprite2D = $ItemSprite

@onready var interaction_hint : Label = get_node_or_null("InteractionHint") as Label

var player_in_range : Node = null

var is_picking_up : bool = false

func _ready() -> void:
	update_item_visual()
	
	if Engine.is_editor_hint():
		return
		
	if interaction_hint != null:
		interaction_hint.hide()
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

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
func _process(_delta : float) -> void:
	if auto_pick:
		return
					
	if player_in_range == null:
		return
		
	if Input.is_action_just_pressed("Interaction"):
		pick_up()
			
func _on_body_entered(body : Node) -> void:
	if not body.is_in_group("player"):
		return
		
	player_in_range = body
	
	if auto_pick:
		pick_up()
		return
	
	if interaction_hint != null:
		interaction_hint.text = "按E拾取"
		interaction_hint.show()

func _on_body_exited(body : Node) -> void:
	if body != player_in_range:
		return
		
	player_in_range = null
	
	if interaction_hint != null:
		interaction_hint.hide()
		
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
	
	amount = clampi(remaining_amount, 0, original_amount - added_amount)
	##全部拾取成功，立即关闭检测并删除
	if amount <= 0:
		monitoring = false
		monitorable = false
		
		if interaction_hint != null:
			interaction_hint.hide()
			
		queue_free()
		return
	is_picking_up = false

func update_remaining_item() -> void:
	print("部分拾取成功， 地上还剩:", amount, "个", item_data.item_id)
	
	if interaction_hint != null:
		interaction_hint.text = "按E拾取（剩余 %d）" %amount
		
func show_inventory_full_message() -> void:
	print("背包空间不足，无法拾取：", item_data.item_id)
	
	if interaction_hint != null:
		interaction_hint.text = "背包空间不足"
		interaction_hint.show()
		
