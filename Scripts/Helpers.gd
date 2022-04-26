extends Node

func apply_camara_shake(percentage):
	var cameras = get_tree().get_nodes_in_group("camera")
	if (cameras.size() > 0):
		cameras[0].apply_shake(percentage)
