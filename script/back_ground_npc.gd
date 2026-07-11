#backgroundNPC
extends StaticBody2D


func play_animation(anim_name:String):
	if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
	else:
		push_error("缺少这个动画：", anim_name)
	
	
