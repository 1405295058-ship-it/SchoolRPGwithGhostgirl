extends RefCounted
class_name QuestWorldResolver

var world_state := {}
var event_state := {}

func set_up_resolver(world_state_data:Dictionary, event_state_data:Dictionary)->void:
	world_state = world_state_data.duplicate()
	event_state = event_state_data.duplicate()

func on_quest_stage_entered(quest_name:String, state_num:String):
	var change_state_record = resolve_change_state(quest_name, state_num)
	var action_state_record = resolve_action_state(quest_name, state_num)
	
	return {
		"world_change":change_state_record,
		"event_change":action_state_record
	}
func resolve_change_state(quest_name:String, state_num:String)->Array:
	if check_is_quest_available(world_state, quest_name, state_num):	
		var world_change = world_state[quest_name]["quest_states"][state_num]
		return world_change
	return []
	
func resolve_action_state(quest_name:String, state_num:String)->Array:
	if check_is_quest_available(event_state, quest_name, state_num):	
		var event_change = event_state[quest_name]["quest_states"][state_num]
		return event_change
	return []

func check_is_quest_available(state_data:Dictionary, quest_name:String, state_num:String):
	var quest_change = state_data.get(quest_name,{})
	var quest_state = quest_change.get("quest_states",{})
	var state_change = quest_state.get(state_num,{})
	if state_change.is_empty():
		return false
	return true
	
# world_change	
#[{
#					"scene":  ["Forecourt"],
#					"object_ID":"npc_Mike" ,
#					"group": "NPC",
#					"change": {
#								"visible": true,
#								"position":[-1828.0, 2663.0],
#								"facing_dir":[0,1]
#							}]
#state_change
#[{
#							"scene": ["Home_player_room"],
#							"object_ID": "CGDirector",
#							"group":"CGDirector",
#							"action": {
#								
#										"play_animation":
#												{
#													"anim_name":"intro_0"
#												}
#									}
#								}]
