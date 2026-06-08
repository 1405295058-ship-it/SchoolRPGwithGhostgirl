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

signal change_week_period
signal change_day_period

var current_week_preiod = "monday"
var current_day_period = "morning"
##可能用于存档
var start_week_period = "friday"
var start_day_period = "night_time"


func _ready() -> void:
	set_up_initial_period()

func set_up_initial_period():
	current_week_preiod = start_week_period
	current_day_period = start_day_period
	change_week_period.emit()
	change_day_period.emit()
func process_to_next_week_period():
	var current_week_period_index = week_period.find(current_week_preiod)
	current_week_period_index += 1
	if current_week_period_index >= week_period.size():
		current_week_period_index = 0
	current_week_preiod = week_period[current_week_period_index]
	change_week_period.emit()

func process_to_next_day_period():
	var current_day_period_index = day_period.find(current_day_period)
	current_day_period_index += 1
	if current_day_period_index >= day_period.size():
		current_day_period_index = 0
		process_to_next_week_period()
	current_day_period = day_period[current_day_period_index]
	change_day_period.emit()
		
