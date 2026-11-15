extends RefCounted
class_name SceneApplyer

func apply_change(changes:Array, current_scene:Node):
	for change in changes:
		var object_id = change.get("object_ID","")
		var object_group = change.get("group","")
		
		var object:Node = find_object_in_scene(object_id, object_group, current_scene)
		
		if object == null:
			push_error("没有找到这个object:",object_id)
			continue
		
		if object.has_method("apply_world_change"):
			object.apply_world_change(change["change"])
		else:
			push_error("这个object没有接口：", object_id)
				

func find_object_in_scene(object_id:String, group:String, current_scene: Node)->Node:
	var nodes = current_scene.get_tree().get_nodes_in_group(group)

	for node in nodes:
		if node != current_scene and not current_scene.is_ancestor_of(node):
			continue
		if "ID" in node and node.ID == object_id:
			return node

	return null
	
	
	
#{
#					"object_ID":object_id,
#					"object_group":object_group,
#					"change":change.duplicate()
#				}
