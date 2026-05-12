extends CharacterBody2D

var dialog_json_path = ""
var dialog_data = {}
var current_dialog_list = []

const face_map = {
	"normal":"res://art/face/Linker说话.png"
	
	
}

const defult_dialog = 	[
							{
								"text":"别来烦我呀！",
								"emotion":"normal"
							},
							{
								"text":"我在升维呢。",
								"emotion":"normal"
							}
						]
						

func interact(player):	
	DialogBox.start_dialog(current_dialog_list,face_map,defult_dialog)
	
