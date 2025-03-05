extends Node3D

@onready var lightwall = preload("res://lightwallseg.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# i knew shit was gonna be like this when i mess with vectors
# godmman
func _on_player_spawn_lw():
	var las_pos = $Player.get_last_pos()
	var glo_pos = $Player.get_global_position()
	# updated every loop, but only last value used
	var new_last_pos = Vector3.ZERO
	# revealed to this function in a dream
	var lw_width = 2
	# because of the lazy height below
	var distance = (las_pos*Vector3(1,0,1)).distance_to(glo_pos*Vector3(1,0,1))
	print("Distance: ", distance)
	var divcount = ceil(distance/lw_width)
	# lazy, do this better
	var height = glo_pos.y
	var x1 = las_pos.x
	var z1 = las_pos.z
	var x2 = glo_pos.x
	var z2 = glo_pos.z
	for q in range(1,divcount):
		var lw_instance = lightwall.instantiate()
		$trails.add_child(lw_instance)
		var p = divcount-q
		lw_instance.set_global_position(Vector3( (p*x1+q*x2)/divcount, height, p*z1+q*z2/divcount ))
		lw_instance.set_global_rotation($Player.get_last_rot())
		new_last_pos = Vector3( (p*x1+q*x2)/divcount, height, p*z1+q*z2/divcount )
	$Player.set_last_pos(new_last_pos)
	$Player.set_last_rot($Player.get_last_rot())

#func _on_player_spawn_lw():
#	var lw_instance = lightwall.instantiate()
#	$trails.add_child(lw_instance)
#	lw_instance.global_position = $Player.get_last_pos()
#	lw_instance.global_rotation = $Player.get_last_rot()
