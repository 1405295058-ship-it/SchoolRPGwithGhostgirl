extends RefCounted
class_name NPCStateMachine

var npc:NPCBase

var current_state: NPCState
var current_state_name: StringName = &""

var states: Dictionary[StringName, NPCState] = {}


func _init(p_npc: Node) -> void:
	npc = p_npc
	register_all_states()
	


func register_all_states() -> void:
	add_state(&"idle",IdleState.new(npc,self))
	add_state(&"following",FollowingState.new(npc,self))
	add_state(&"background_idle",BackgroundIdleState.new(npc,self))
	add_state(&"on_class_state",OnClassState.new(npc,self))
func add_state(
	state_name: StringName,
	state: NPCState
) -> void:
	states[state_name] = state


func change_state(state_name: StringName,data: Dictionary = {}) -> void:
	if not states.has(state_name):
		push_error("不存在此状态：", state_name)
		return

	if current_state != null:
		current_state.exit()

	current_state_name = state_name
	current_state = states[state_name]

	current_state.enter(data)


func update(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)

func shutdown() -> void:
	if current_state != null:
		current_state.exit()

	current_state = null
	current_state_name = &""

	states.clear()
	npc = null
