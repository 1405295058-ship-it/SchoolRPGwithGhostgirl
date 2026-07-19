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
	"dinner_time":{"timer1":"DIN","timer2":"NER"},
	"night_time":{"timer1":"NIG","timer2":"HT"},
}

@onready var cg_up_fade_layer := $CgUpFadeLayer
@onready var cg_down_fade_layer := $CgBottomFadeLayer

@onready var objective_block_path = preload("res://sence/需要path的/finish_blockin_normal_quest_ui.tscn")

var is_tracking_quest := false
func _ready() -> void:
	EventBus.change_day_period.connect(update_watch_timer)
	EventBus.change_week_period.connect(update_watch_timer)
	EventBus.tracking_quest_changed.connect(update_track_quest)
	EventBus.start_play_cg.connect(on_cg_started_play)
	EventBus.end_play_cg.connect(on_cg_ended_play)
	update_track_quest()
	hide_fade_layer()

func on_cg_started_play():
	hide_head_up_ui()
	$SkipTip.show()
	show_fade_layer_when_cg_start()
func on_cg_ended_play(_anim_name):
	$SkipTip.hide()
	await hide_fade_layer_when_cg_end()
	show_head_up_ui()
	
func show_head_up_ui():
	$TimeShowerWatch.show()	
	if is_tracking_quest:
		$QuestShowUpTitleBackground.show()	
func hide_head_up_ui():
	$TimeShowerWatch.hide()	
	$QuestShowUpTitleBackground.hide()
	
	
func update_track_quest():
	for child in $QuestShowUpTitleBackground/VBoxContainer.get_children():
		child.queue_free()
	
	var quest_name = QuestManager.current_tracking_quest
	var objectives = QuestManager.find_objectives_by_quest_name(quest_name)
	print(objectives)
	if quest_name == "":
		$QuestShowUpTitleBackground.hide()
		is_tracking_quest = false
		return
	$QuestShowUpTitleBackground.show()
	is_tracking_quest = true
	$QuestShowUpTitleBackground/title.text = quest_name
	if objectives.size() > 0:
		for objective in objectives:
			var objective_block = objective_block_path.instantiate()
			var objective_node = objective_block.get_node("objectives")
			var objective_key = objective.get("in_code","")
			if QuestManager.is_objective_time_available(objective):
				objective_node.text = objective.get("text","")
				var current_amount = QuestManager.quest_progress_data[quest_name
				]["objective_progress"].get(objective_key,0)
				var target_amount = objective.get("target_amount",1)
				if target_amount >1:
					target_amount = int(target_amount)
					current_amount = int(current_amount)
					var add_text = str(current_amount)+"/"+str(target_amount)
					objective_node.text += add_text
				
			else:
				objective_node.text = objective.get("time_hint","")
			$QuestShowUpTitleBackground/VBoxContainer.add_child(objective_block)
func update_watch_timer():
	$TimeShowerWatch.show()
	$TimeShowerWatch/SymbolAnimation.play("SymbolAnimation")
	var current_week_period = TimeManager.current_week_period
	var current_day_period = TimeManager.current_day_period
	$TimeShowerWatch/Date.text = week_time_map[current_week_period]
	$TimeShowerWatch/HBoxContainer/Time.text = day_time_map[current_day_period]["timer1"]		
	$TimeShowerWatch/HBoxContainer/Time2.text = day_time_map[current_day_period]["timer2"]		

func show_fade_layer_when_cg_start():
	var tween = get_tree().create_tween()	
	tween.tween_property(cg_up_fade_layer,"scale:y",1,1)
	tween.parallel().tween_property(cg_down_fade_layer,"scale:y",1,1)
	await tween.finished
	tween.kill()
func hide_fade_layer_when_cg_end():
	var tween = get_tree().create_tween()	
	tween.tween_property(cg_up_fade_layer,"scale:y",0,1)
	tween.parallel().tween_property(cg_down_fade_layer,"scale:y",0,1)
	await tween.finished
	tween.kill()
func hide_fade_layer():
	$SkipTip.hide()
	cg_up_fade_layer.scale.y = 0
	cg_down_fade_layer.scale.y = 0
