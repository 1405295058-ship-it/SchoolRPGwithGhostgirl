extends StaticBody2D


@export var warning_dialog =[
	{
		"speaker":"player",
		"text": "（上面是高年级的宿舍，最好还是别去。。。）",
		"emotion": "normal"
	}
]

func interact(_player):
	DialogBox.start_dialog([], warning_dialog)
	
