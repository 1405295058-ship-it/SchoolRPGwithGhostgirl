extends TextureRect

@onready var layer_map = {
	"save_slot":{
					"button": $ScrollContainer/VBoxContainer/SaveButton,
					"interface":$SaveSlot
				},
	"load_slot":{
					"button": $ScrollContainer/VBoxContainer/LoadButton,
					"interface":$LoadSlots
				},
}

func _ready() -> void:
	initialised()
	
func hide_all_layers():
	for layer in layer_map:
		var interface = layer_map[layer].get("interface",null)
		if interface != null:
			interface.hide()

func show_layer(layer_name:String):
	hide_all_layers()
	var layer_info = layer_map.get(layer_name,{})
	
	var interface = layer_info.get("interface",null)
	if interface != null:
		interface.show()
	 
	
func initialised():
	hide_all_layers()


func _on_save_button_pressed() -> void:
	show_layer("save_slot")
	
func _on_load_button_pressed() -> void:
	show_layer("load_slot")
