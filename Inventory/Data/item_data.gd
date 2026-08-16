class_name ItemData
extends Resource

##用来存档和识别道具
##道具id要唯一
@export var item_id : String = ""


##显示在UI上的名字
@export var item_name : String = ""

##道具说明
@export_multiline() var description : String = ""

##背包中显示的图标
@export var icon : Texture2D

@export_range(1, 9999, 1)
var max_stack_size : int = 999
