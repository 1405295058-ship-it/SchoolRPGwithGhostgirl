extends Node

const QUEST_DATA_JSON_PATH := \
	"res://QuestResources/QuestData/QuestData.json"

var quest_data: Dictionary


func _ready() -> void:
	check_json_file(QUEST_DATA_JSON_PATH)


func check_json_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("JSON 文件地址不存在：" + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("JSON 文件无法打开：" + path)
		return

	var json_text := file.get_as_text()

	var json := JSON.new()
	var error_code := json.parse(json_text)

	if error_code != OK:
		push_error(
			"JSON 语法错误\n文件：%s\n第 %d 行\n原因：%s"
			% [
				path,
				json.get_error_line(),
				json.get_error_message()
			]
		)
		return

	if not json.data is Dictionary:
		push_error("QuestData 最外层必须是 Dictionary")
		return

	quest_data = json.data

	print("JSON 语法检查通过：" + path)

	valid_quest_data(quest_data)


func valid_quest_data(data: Dictionary) -> void:
	for quest_name in data:
		var quest = data[quest_name]

		if not quest is Dictionary:
			push_error(
				"任务【%s】的内容必须是 Dictionary"
				% quest_name
			)
			continue

		valid_quest(str(quest_name), quest)

	print("QuestData 结构检查结束")


func valid_quest(
	quest_name: String,
	quest: Dictionary
) -> void:
	var required_fields := [
		"type",
		"quest_states"
	]

	var all_valid_fields := [
		"type",
		"quest_states",
		"active_method"
	]

	var valid_quest_types := [
		"main",
		"sub"
	]

	# 检查必须字段
	for field in required_fields:
		if not quest.has(field):
			push_error(
				"任务【%s】缺少必须字段：%s"
				% [quest_name, field]
			)
			return

	# 检查是否出现了未定义字段
	for key in quest:
		if key not in all_valid_fields:
			push_error(
				"任务【%s】存在不符合规范的字段：%s"
				% [quest_name, key]
			)

	# 检查 type
	if not quest["type"] is String:
		push_error(
			"任务【%s】的 type 必须是 String"
			% quest_name
		)
		return

	if quest["type"] not in valid_quest_types:
		push_error(
			"任务【%s】的 type 必须是 main 或 sub，当前为：%s"
			% [quest_name, quest["type"]]
		)

	# 检查 quest_states
	if not quest["quest_states"] is Dictionary:
		push_error(
			"任务【%s】的 quest_states 必须是 Dictionary"
			% quest_name
		)
		return

	# 检查可选的 active_method
	if quest.has("active_method"):
		if not quest["active_method"] is Dictionary:
			push_error(
				"任务【%s】的 active_method 必须是 Dictionary"
				% quest_name
			)
		else:
			valid_active_method(
				quest_name,
				quest["active_method"]
			)

	valid_quest_states(
		quest_name,
		quest["quest_states"]
	)


func valid_active_method(
	quest_name: String,
	active_method: Dictionary
) -> void:
	var required_fields := [
		"target_id",
		"active_event"
	]

	var all_valid_fields := [
		"target_id",
		"active_event",
		"time_condition",
		"time_hint"
	]

	for field in required_fields:
		if not active_method.has(field):
			push_error(
				"任务【%s】的 active_method 缺少必须字段：%s"
				% [quest_name, field]
			)

	for key in active_method:
		if key not in all_valid_fields:
			push_error(
				"任务【%s】的 active_method 存在无效字段：%s"
				% [quest_name, key]
			)

	if active_method.has("target_id"):
		if not active_method["target_id"] is String:
			push_error(
				"任务【%s】active_method.target_id 必须是 String"
				% quest_name
			)

	if active_method.has("active_event"):
		if not active_method["active_event"] is String:
			push_error(
				"任务【%s】active_method.active_event 必须是 String"
				% quest_name
			)

	if active_method.has("time_hint"):
		if not active_method["time_hint"] is String:
			push_error(
				"任务【%s】active_method.time_hint 必须是 String"
				% quest_name
			)

	if active_method.has("time_condition"):
		valid_time_condition(
			quest_name,
			"active_method",
			active_method["time_condition"]
		)


func valid_quest_states(
	quest_name: String,
	quest_states: Dictionary
) -> void:
	if quest_states.is_empty():
		push_error(
			"任务【%s】的 quest_states 不能为空"
			% quest_name
		)
		return

	for state_key in quest_states:
		var state_data = quest_states[state_key]

		if not str(state_key).is_valid_int():
			push_error(
				"任务【%s】的阶段 Key 必须是数字字符串，当前为：%s"
				% [quest_name, state_key]
			)

		if not state_data is Dictionary:
			push_error(
				"任务【%s】阶段【%s】的内容必须是 Dictionary"
				% [quest_name, state_key]
			)
			continue

		valid_single_quest_state(
			quest_name,
			str(state_key),
			state_data
		)


func valid_single_quest_state(
	quest_name: String,
	state_key: String,
	state_data: Dictionary
) -> void:
	var required_fields := [
		"quest_description",
		"objective"
	]

	var all_valid_fields := [
		"quest_description",
		"objective",
		"time_condition",
		"time_hint"
	]

	# 检查必须字段
	for field in required_fields:
		if not state_data.has(field):
			push_error(
				"任务【%s】阶段【%s】缺少必须字段：%s"
				% [quest_name, state_key, field]
			)

	# 检查额外字段
	for key in state_data:
		if key not in all_valid_fields:
			push_error(
				"任务【%s】阶段【%s】存在无效字段：%s"
				% [quest_name, state_key, key]
			)

	# quest_description
	if state_data.has("quest_description"):
		if not state_data["quest_description"] is String:
			push_error(
				"任务【%s】阶段【%s】的 quest_description 必须是 String"
				% [quest_name, state_key]
			)

	# time_hint 可选
	if state_data.has("time_hint"):
		if not state_data["time_hint"] is String:
			push_error(
				"任务【%s】阶段【%s】的 time_hint 必须是 String"
				% [quest_name, state_key]
			)

	# time_condition 可选
	if state_data.has("time_condition"):
		valid_time_condition(
			quest_name,
			"阶段 " + state_key,
			state_data["time_condition"]
		)

	# objective
	if state_data.has("objective"):
		if not state_data["objective"] is Array:
			push_error(
				"任务【%s】阶段【%s】的 objective 必须是 Array"
				% [quest_name, state_key]
			)
		else:
			valid_objectives(
				quest_name,
				state_key,
				state_data["objective"]
			)


func valid_objectives(
	quest_name: String,
	state_key: String,
	objectives: Array
) -> void:
	if objectives.is_empty():
		push_error(
			"任务【%s】阶段【%s】的 objective 不能为空"
			% [quest_name, state_key]
		)
		return

	for objective_index in objectives.size():
		var objective = objectives[objective_index]

		if not objective is Dictionary:
			push_error(
				"任务【%s】阶段【%s】目标【%d】必须是 Dictionary"
				% [
					quest_name,
					state_key,
					objective_index + 1
				]
			)
			continue

		valid_single_objective(
			quest_name,
			state_key,
			objective_index,
			objective
		)


func valid_single_objective(
	quest_name: String,
	state_key: String,
	objective_index: int,
	objective: Dictionary
) -> void:
	var required_fields := [
		"text",
		"in_code",
		"target_amount"
	]

	var all_valid_fields := [
		"text",
		"target_id",
		"in_code",
		"target_amount",
		"time_condition",
		"time_hint"
	]

	var objective_position := (
		"任务【%s】阶段【%s】目标【%d】"
		% [
			quest_name,
			state_key,
			objective_index + 1
		]
	)

	# 检查必须字段
	for field in required_fields:
		if not objective.has(field):
			push_error(
				"%s 缺少必须字段：%s"
				% [objective_position, field]
			)

	# 检查额外字段
	for key in objective:
		if key not in all_valid_fields:
			push_error(
				"%s 存在无效字段：%s"
				% [objective_position, key]
			)

	# text
	if objective.has("text"):
		if not objective["text"] is String:
			push_error(
				"%s 的 text 必须是 String"
				% objective_position
			)

	# target_id 可选
	if objective.has("target_id"):
		if not objective["target_id"] is String:
			push_error(
				"%s 的 target_id 必须是 String"
				% objective_position
			)

	# in_code
	if objective.has("in_code"):
		if not objective["in_code"] is String:
			push_error(
				"%s 的 in_code 必须是 String"
				% objective_position
			)

	# target_amount
	if objective.has("target_amount"):
		if not objective["target_amount"] is int and not objective["target_amount"] is float:
			push_error(
				"%s 的 target_amount 必须是 int"
				% objective_position
			)
		elif objective["target_amount"] <= 0:
			push_error(
				"%s 的 target_amount 必须大于 0"
				% objective_position
			)

	# time_hint 可选
	if objective.has("time_hint"):
		if not objective["time_hint"] is String:
			push_error(
				"%s 的 time_hint 必须是 String"
				% objective_position
			)

	# time_condition 可选
	if objective.has("time_condition"):
		valid_time_condition(
			quest_name,
			"阶段 %s 的目标 %d"
			% [state_key, objective_index + 1],
			objective["time_condition"]
		)


func valid_time_condition(
	quest_name: String,
	position: String,
	time_condition: Variant
) -> void:
	if not time_condition is Dictionary:
		push_error(
			"任务【%s】%s 的 time_condition 必须是 Dictionary"
			% [quest_name, position]
		)
		return

	var valid_fields := [
		"day_period",
		"week_period"
	]

	var valid_day_periods := [
		"morning",
		"lunch_time",
		"dinner",
		"night"
	]

	var valid_week_periods := [
		"monday",
		"tuesday",
		"wednesday",
		"thursday",
		"friday",
		"saturday",
		"sunday"
	]

	for key in time_condition:
		if key not in valid_fields:
			push_error(
				"任务【%s】%s 的 time_condition 存在无效字段：%s"
				% [quest_name, position, key]
			)

	if time_condition.has("day_period"):
		valid_string_array(
			quest_name,
			position + ".day_period",
			time_condition["day_period"],
			valid_day_periods
		)

	if time_condition.has("week_period"):
		valid_string_array(
			quest_name,
			position + ".week_period",
			time_condition["week_period"],
			valid_week_periods
		)


func valid_string_array(
	quest_name: String,
	position: String,
	value: Variant,
	valid_values: Array
) -> void:
	if not value is Array:
		push_error(
			"任务【%s】%s 必须是 Array"
			% [quest_name, position]
		)
		return

	for item in value:
		if not item is String:
			push_error(
				"任务【%s】%s 中的内容必须是 String"
				% [quest_name, position]
			)
			continue

		if item not in valid_values:
			push_error(
				"任务【%s】%s 存在无效值：%s"
				% [quest_name, position, item]
			)
