#原装函数init  enter   update   exit 
#变量 npc self   npc 的 state Machine
extends NPCState
class_name IdleAnimationState

func _init(
	p_npc: NPCBase,
	p_state_machine: NPCStateMachine
) -> void:
	super(p_npc, p_state_machine)


func enter(data: Dictionary) -> void:
	var anim_name: String = data.get("anim_name", "")

	npc.play_animation(anim_name)
