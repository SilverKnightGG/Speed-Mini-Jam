class_name ClusterArea extends Area2D


func _on_area_entered(area):
	for child in get_children():
		if child.has_node("Mover"):
			child.get_node("Mover").set_monitoring(true)
