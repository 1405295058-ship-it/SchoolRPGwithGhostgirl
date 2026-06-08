extends Area2D

@export var ID = ""





func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var event_name = "arrive_" + ID
		QuestManager.check_event_is_quest_need(event_name,1)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var event_name = "leave_" + ID
		QuestManager.check_event_is_quest_need(event_name,1)
