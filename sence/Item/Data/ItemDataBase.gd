# ItemDatabase.gd Autoload
extends Node

var items = {
	"player_money_card": preload("res://sence/Item/MoneyCard.tres")
	
}

func get_item(item_id: String) -> Need_pick_Item:
	return items.get(item_id)
