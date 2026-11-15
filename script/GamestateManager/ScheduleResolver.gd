extends RefCounted
class_name ScheduleResolver


var default_object_schedule := {}

func set_up_resolver(schedule_data):
	default_object_schedule = schedule_data
	
	
func resolve_schedule(
	scene_id,
	week_period,
	day_period
)-> Array:
	var schedule_changes = []
	
	for key in default_object_schedule:
		var object_schedule = default_object_schedule[key].get("schedule",{})
		
		if object_schedule.is_empty():
			push_error("object",key,"缺少schedule")
			continue
		
		var current_week_schedule = object_schedule .get(week_period, {})
		
		var current_day_schedule = current_week_schedule.get(day_period,{})
		
		var object_id = current_day_schedule.get("object_ID", "")
		var object_group = current_day_schedule.get("group", "")
		
		var changes = current_day_schedule.get("changes",[])
		
		for change in changes:

			if change.get("scene", "") != scene_id:
				continue
			
			
			schedule_changes.append(
				{
					"object_ID":object_id,
					"group":object_group,
					"change":change.duplicate()
				}
			)			
		
		
	
	return schedule_changes
		
