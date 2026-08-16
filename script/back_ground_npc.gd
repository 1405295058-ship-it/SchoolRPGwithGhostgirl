extends NPCBase
class_name BackGroundNPC

@export var gender:all_gender = all_gender.no
enum all_gender {
	boy,
	girl,
	no
}

func _ready() -> void:
	super._ready()

func get_gender():
	match gender:
		all_gender.boy:
			return "boy"
		all_gender.girl:
			return "girl"
		all_gender.no:
			return null
