# ItemDatabase.gd Autoload
extends Node

var items = {
	"player_money_card": preload("res://sence/Item/MoneyCard.tres"),
	"sean_s_money_card": preload("res://sence/Item/LaoShiCard.tres"),
}

func get_item(item_id: String) -> ItemData:
	if not items.has(item_id):
		push_error("不存在此道具：" + item_id)
		return null
		
	return items.get(item_id) as ItemData
