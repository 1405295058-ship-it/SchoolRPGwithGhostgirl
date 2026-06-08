extends CanvasLayer
var week_time_map = {
	"monday":"MON",
	"tuesday":"TUE",
	"wednesday":"WED",
	"thursday":"THU",
	"friday":"FRI",
	"saturday":"SAT",
	"sunday":"SUN",
}
var day_time_map = {
	"morning":{"timer1":"MOR","timer2":"NING"},
	"lunch_time":{"timer1":"LUN","timer2":"CH"},
	"dinner_time":{"timer1":"DIN","timer2":"NNER"},
	"night_time":{"timer1":"NIG","timer2":"HT"},
}
##明天要连信号 然后写函数
@onready var objective_block_path = preload("res://sence/需要path的/finish_blockin_normal_quest_ui.tscn")
func _ready() -> void:
	TimeManager.change_day_period.connect(update_watch_timer)
	TimeManager.change_week_period.connect(update_watch_timer)
	QuestManager.tracking_quest_changed.connect(update_track_quest)
	update_track_quest()

func update_track_quest():
	for child in $QuestShowUpTitleBackground/VBoxContainer.get_children():
		child.queue_free()
	
	var quest_name = QuestManager.current_tracking_quest
	var objectives = QuestManager.find_objectives_by_quest_name(quest_name)
	if quest_name == "":
		$QuestShowUpTitleBackground.hide()
		return
	$QuestShowUpTitleBackground.show()
	$QuestShowUpTitleBackground/title.text = quest_name
	if objectives.size() > 0:
		for objective in objectives:
			var objective_block = objective_block_path.instantiate()
			var objective_node = objective_block.get_node("objectives")
			var objective_key = objective.get("in_code","")
			objective_node.text = objective.get("text","")
			var current_amount = QuestManager.quest_progress_data[quest_name
			]["objective_progress"].get(objective_key,0)
			var target_amount = objective.get("target_amount",1)
			if target_amount >1:
				target_amount = int(target_amount)
				current_amount = int(current_amount)
				var add_text = str(current_amount)+"/"+str(target_amount)
				objective_node.text += add_text
			$QuestShowUpTitleBackground/VBoxContainer.add_child(objective_block)
func update_watch_timer():
	$TimeShowerWatch.show()
	$TimeShowerWatch/SymbolAnimation.play("SymbolAnimation")
	var current_week_period = TimeManager.current_week_preiod
	var current_day_period = TimeManager.current_day_period
	print("week = ", current_week_period, " type = ", typeof(current_week_period))
	print("day = ", current_day_period, " type = ", typeof(current_day_period))
	print("week map has = ", week_time_map.has(current_week_period))
	print("day map has = ", day_time_map.has(current_day_period))
	$TimeShowerWatch/Date.text = week_time_map[current_week_period]
	$TimeShowerWatch/HBoxContainer/Time.text = day_time_map[current_day_period]["timer1"]		
	$TimeShowerWatch/HBoxContainer/Time2.text = day_time_map[current_day_period]["timer2"]		
