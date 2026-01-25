extends Node3D

var routes := [
	{"A":"B", "B":"C", "C":"D", "D":"A"}
]

func get_route(index : int):
	return routes[index]

func get_random_route():
	return routes.pick_random()

func get_closest_patrol_pos(target_pos : Vector3):
	var closest_patrol_pos = get_child(0).global_position
	for child in get_children():
		var child_pos = child.global_position
		if child_pos.distance_to(target_pos) < closest_patrol_pos.distance_to(target_pos):
			closest_patrol_pos = child_pos
	return closest_patrol_pos
