#DailyRoutineManager.gd
extends Node



enum RoutineStep {
	WAKE_UP,
	GO_TO_SCHOOL,
	MORNING_CLASS,
	LUNCH_FREE,
	AFTERNOON_CLASS,
	EVENING_FREE,
	NIGHT_STUDY,
	NIGHT_FREE
}


var is_pause := false
var is_processing := false
var current_routine = []
var	current_step_index := 1

func _ready() -> void:
	EventBus.increase_routine_by_one_step.connect(go_next_step)
	EventBus.end_free_time.connect(finish_free_time)
	start_day()
	current_step_index = 1
	run_current_step()

func start_weekday_routine() -> void:
	current_routine = [
		RoutineStep.WAKE_UP,
		RoutineStep.GO_TO_SCHOOL,
		RoutineStep.MORNING_CLASS,
		RoutineStep.LUNCH_FREE,
		RoutineStep.AFTERNOON_CLASS,
		RoutineStep.EVENING_FREE,
		RoutineStep.NIGHT_STUDY
	]
func start_weekend_routine() -> void:
	current_routine = [
		RoutineStep.WAKE_UP,
		RoutineStep.LUNCH_FREE,
		RoutineStep.EVENING_FREE,
		RoutineStep.NIGHT_FREE
		
	]
	
	
func start_day():
	if TimeManager.is_weekend():
		start_weekend_routine()
	else:
		start_weekday_routine()
	current_step_index = 0

	
func run_current_step():
	if is_processing:
		return
	if is_pause:
		return
	is_processing = true
	var current_step = current_routine[current_step_index]
	match current_step:
		RoutineStep.WAKE_UP:
			process_routine_wake_up()
		RoutineStep.GO_TO_SCHOOL:
			print("去学校")
			go_next_step()
		RoutineStep.MORNING_CLASS:
			print("早课")
			go_next_step()
		RoutineStep.LUNCH_FREE:
			print("进入中午活动")
			is_processing = false
		RoutineStep.AFTERNOON_CLASS:
			print("下午课")
			go_next_step()
		RoutineStep.EVENING_FREE:
			print("进入黄昏时间")
			is_processing = false
		RoutineStep.NIGHT_STUDY:
			print("晚上学习")
			go_next_step()
		RoutineStep.NIGHT_FREE:
			print("晚上自由活动")
			is_processing = false
func go_next_step():
	current_step_index += 1
	
	if current_step_index >= current_routine.size():
		start_day()
		is_processing = false
		run_current_step()
		return
	
	is_processing = false
	run_current_step()

func finish_free_time():
	var current_step = current_routine[current_step_index]
	if current_step != RoutineStep.LUNCH_FREE and current_step != RoutineStep.EVENING_FREE and current_step != RoutineStep.NIGHT_FREE:
		return
	TimeManager.process_to_next_day_period()
	go_next_step()
	
func pause_daily_routine():
	is_pause = true
func unpause_daily_routine():
	is_pause = false



func play_cg_and_wait(anim_name: String) -> void:
	EventBus.play_this_animation.emit(anim_name,false)
	
	var finished_anim_name: String = await EventBus.end_play_cg
	go_next_step()
	if finished_anim_name != anim_name:
		push_warning(
			"等待的是 " + anim_name +
			"，但结束的是 " + finished_anim_name
		)
		
func process_routine_wake_up():
	await SceneManager.change_scene_to("BoyAccommodationGF")
	print("现在起床")
	await play_cg_and_wait("daily_routine_wake_up")
