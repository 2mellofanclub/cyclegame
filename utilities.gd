extends Node

func look_at_xz(node: Node3D, target: Vector3, up: Vector3 = Vector3(0, 1, 0), use_model_front: bool = false):
	if node.global_position == target:
		return
	var xz_target = target * Vector3(1, 0, 1) + Vector3(0, node.global_position.y, 0)
	node.look_at(xz_target, up, use_model_front)
