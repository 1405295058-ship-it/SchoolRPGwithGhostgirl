extends Node2D




func update_hint_mark(unlocked_or_active:String) -> void:
	match unlocked_or_active:
		"unlocked":
			show()
			$UnlockedQuestHint.play("default")
			$UnlockedQuestHint.show()
			$NextStateHintSprite.hide()
		"active":
			show()
			$NextStateHint.play("NextStateHint")
			$NextStateHintSprite.show()
			$UnlockedQuestHint.hide()
		"":
			hide_the_hint()
func hide_the_hint():
	hide()
