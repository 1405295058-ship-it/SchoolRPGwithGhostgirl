extends Button




var is_hovering := false

func _on_mouse_entered() -> void:
	is_hovering = true
	
	await get_tree().create_timer(1.0).timeout
	
	if is_hovering:
		$Discription.show()

func _on_mouse_exited() -> void:
	is_hovering = false
	$Discription.hide()
