extends Node

var pause_reason:Dictionary = {}

func request_pause(reason:String):
	pause_reason[reason] = true
	update_pause_state()
	
func release_pause(reason:String):
	pause_reason.erase(reason)	
	update_pause_state()
func update_pause_state():
	get_tree().paused = not pause_reason.is_empty()

func is_paused()->bool:
	return not pause_reason.is_empty()
	
