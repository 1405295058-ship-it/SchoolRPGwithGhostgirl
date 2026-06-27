extends Node

#QuestManager

signal quest_state_changed(quest_name:String)
signal a_quest_finished(quest_name:String)
signal a_quest_state_finished(quest_name:String,quest_state_str:String)
signal quest_hint_should_refresh
signal tracking_quest_changed
signal unlocked_quest_world_should_apply(quest_name:String)

#TimeManager
signal time_context_changed(current_week_period:String,current_day_period:String)
signal change_week_period
signal change_day_period

#userUI
signal set_tracking_quest(quest_name)

#sceneManager
signal scene_changed
