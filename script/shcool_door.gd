extends Node2D

@export var fade_alpha := 0.35      # 虚化到多少透明度
@export var fade_speed := 8.0       # 淡入淡出速度（越大越快）
@export var behind_offset := 0.0    # 需要的话可微调“判定线”

@onready var fade_area: Area2D = $Area2D
@onready var visual: CanvasItem = $AnimatedSprite2D

var _should_fade = false

func _ready() -> void:
	# 连接 Area2D 的信号：有人进来/出去就自动回调下面两个函数
	fade_area.body_entered.connect(_on_body_entered)
	fade_area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# 根据状态决定目标透明度
	var target := fade_alpha if _should_fade else 1.0

	# 平滑过渡到目标透明度（不想平滑就看下面“立刻切换版”）
	var a := visual.modulate.a
	visual.modulate.a = lerp(a, target, 1.0 - exp(-fade_speed * delta))

func _on_body_entered(body: Node) -> void:
	# 只对玩家生效（要求玩家在 group "player"）
	if body.is_in_group("player"):
		_should_fade = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_should_fade = false
	

	
