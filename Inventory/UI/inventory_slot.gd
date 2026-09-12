class_name InventorySlot
extends PanelContainer

signal item_info_requested(item_data : ItemData, bag_id : String, slot_index : int)

@onready var item_icon : TextureRect = $SlotContent/ItemIcon

@onready var amount_label : Label = $SlotContent/AmountLabel

var bag_id : String =""
var slot_index : int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
#===================== setup/ refresh ===================
	

#把UIslot绑定到manager中一个真实的格子, 在InventoryUI.build_bag()调用
func set_up(new_bag_id : String, new_slot_index : int) -> void:
	bag_id = new_bag_id
	slot_index = new_slot_index
	
	refresh()
	
#根据InventoryManager刷新图标, 在InventoryUI.refresh_bag()调用
func refresh() -> void:
	var stack : ItemStack = InventoryManager.get_itemstack(bag_id, slot_index)
	
	if stack == null:
		item_icon.texture = null
		amount_label.text = ""
		amount_label.hide()
		tooltip_text = ""
		
		return
	
	item_icon.texture = stack.item_data.icon
	
	if stack.amount > 1:
		amount_label.text = str(stack.amount)
		amount_label.show()
	else:
		amount_label.text = ""
		amount_label.hide()
		
	tooltip_text = "%s\n%s"%[stack.item_data.item_name, stack.item_data.description]


#======================= drag/ drop =======================


#开始拖拽物体时自调用
func _get_drag_data(_at_position : Vector2) -> Variant:
	var stack: ItemStack = InventoryManager.get_itemstack(bag_id, slot_index)
	
	if stack == null:
		return null
		
	var preview_container := Control.new()
	preview_container.custom_minimum_size = Vector2(64,64)
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	##鼠标拖拽时跟随光标
	var preview_icon := TextureRect.new()
	preview_icon.texture = stack.item_data.icon
	preview_icon.custom_minimum_size = Vector2(64,64)
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	preview_container.add_child(preview_icon)
	
	if stack.amount > 1:
		var preview_amount := Label.new()
		preview_amount.text = str(stack.amount)
		preview_amount.position = Vector2(38,38)
		preview_amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		preview_container.add_child(preview_amount)
	
	set_drag_preview(preview_container)
	
	return {
		"drag_type" : "inventory_item",
		"bag_id" : bag_id,
		"slot_index" : slot_index
		}

#判断当前格子能否放下物体
func _can_drop_data(_at_position : Vector2, data :Variant) -> bool:
	if not data is Dictionary:
		return false
		
	var data_type = data.get("drag_type","")
	if data_type != "inventory_item" : 
		return false
		
	if not data.has("bag_id"):
		return false
		
	if not data.has("slot_index"):
		return false
		
	return true

##松开鼠标放入物体时调用
func _drop_data(_at_position : Vector2, data : Variant) -> void:
	var from_bag_id : String = data["bag_id"]
	var from_slot_index : int = data["slot_index"]
	
	InventoryManager.move_or_swap_stack(from_bag_id, from_slot_index, bag_id, slot_index)	

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
		
	var mouse_event := event as InputEventMouseButton
	
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
		
	if not mouse_event.pressed:
		return
		
	var stack : ItemStack = InventoryManager.get_itemstack(bag_id,slot_index)
	
	if stack == null:
		return
		
	if stack.item_data == null:
		return
		
	item_info_requested.emit(stack.item_data, bag_id, slot_index)
	
	
