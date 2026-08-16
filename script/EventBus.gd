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
signal set_tracking_quest(quest_name:String)

#sceneManager
signal scene_changed


#DialogBox
signal on_dialog_finished

#GameManager
signal play_this_animation(anim_name:String,is_play_once_only:bool)
signal call_this_progress_blocker(blocker_id:String,action:bool,warning_dialog_change:Array )
signal call_this_change_scene_area(area_id:String,action,warning_dialog_change:Array)

#CGdirector
signal start_play_cg
signal end_play_cg(anim_name:String)
signal cg_start_fast_forward()

#DailyRoutineManager
signal increase_routine_by_one_step
signal end_free_time
signal class_start
signal class_end
