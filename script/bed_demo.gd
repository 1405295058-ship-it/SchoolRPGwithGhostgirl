extends StaticBody2D


func interact(_player):
	await FadeLayer.fade_out(1)
	EventBus.end_free_time.emit()
	await FadeLayer.fade_in(1)
	
	
