extends StaticBody2D


func interact(_player):
	await FadeLayer.fade_out(1)
	TimeManager.process_to_next_day_period()
	await FadeLayer.fade_in(1)
	
	
