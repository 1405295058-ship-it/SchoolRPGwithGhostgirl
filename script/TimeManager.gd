extends Node


var week_period=[
	"monday",
	"tuesday",
	"wednesday",
	"thursday",
	"friday",
	"saturday",
	"sunday"
]
var day_period = [
	"morning",
	"lunch_time",
	"dinner_time",
	"night_time"
]


var current_week_period = "monday"
var current_day_period = "morning"
##可能用于存档
var start_week_period = "sunday"
var start_day_period = "lunch_time"


func _ready() -> void:
	set_up_initial_period()

func set_up_initial_period():
	current_week_period = start_week_period
	current_day_period = start_day_period
	EventBus.change_week_period.emit()
	EventBus.change_day_period.emit()
	EventBus.time_context_changed.emit(current_week_period,current_day_period)
func process_to_next_week_period(emit_context_changed := true):
	var current_week_period_index = week_period.find(current_week_period)
	current_week_period_index += 1
	if current_week_period_index >= week_period.size():
		current_week_period_index = 0
	current_week_period = week_period[current_week_period_index]
	EventBus.change_week_period.emit()
	if emit_context_changed:
		EventBus.time_context_changed.emit(current_week_period,current_day_period)

func process_to_next_day_period():
	var current_day_period_index = day_period.find(current_day_period)
	current_day_period_index += 1
	if current_day_period_index >= day_period.size():
		current_day_period_index = 0
		process_to_next_week_period(false)
	current_day_period = day_period[current_day_period_index]
	EventBus.change_day_period.emit()
	EventBus.time_context_changed.emit(current_week_period,current_day_period)
		
func is_time_match(time_condition:Dictionary):
	if time_condition.is_empty():
		return true
	if time_condition.has("day_period"):
		if not time_condition["day_period"].has(current_day_period):
			return false
	if time_condition.has("week_period"):
		if not time_condition["week_period"].has(current_week_period):
			return false	
	return true
