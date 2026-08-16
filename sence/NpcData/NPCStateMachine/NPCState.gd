extends RefCounted
class_name NPCState


var npc:NPCBase
var state_machine:NPCStateMachine

func _init(p_npc:NPCBase,p_state_machine:NPCStateMachine) -> void:
	npc = p_npc
	state_machine = p_state_machine


func enter(_data:Dictionary) -> void:
	pass

func update(_delta:float)->void:
	pass

func exit()->void:
	pass
	
