extends Control


@onready var new_game_button = $VBoxContainer/NewGame

@onready var continue_button = $VBoxContainer/Continue

func _on_new_game_pressed() -> void:
	print("按下按钮咯")
	SaveManager.start_new_game()
	


func _on_continue_pressed() -> void:
	print("加载游戏哈哈哈")
	SaveManager.load_game()
	
	
	
