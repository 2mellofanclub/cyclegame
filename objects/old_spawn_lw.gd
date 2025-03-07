extends Node

const MAX_TRAILS = 6000
var LightWall = load("res://objects/lightwallseg.tscn")


# i knew shit was gonna be like this when i mess with vectors
# godmman
func spawn_lw(Driver):
	var las_pos = Driver.get_last_pos()
	var glo_pos = Driver.get_global_position()
	# updated every loop, but only last value used
	var new_last_pos = Vector3.ZERO
	# revealed to this function in a dream 
	# since lightwall hasn't been instantiated
	var lw_width = 0.6
	var distance = (las_pos).distance_to(glo_pos)
	var divcount = ceil(distance / lw_width)
	var x1 = las_pos.x
	var y1 = las_pos.y
	var z1 = las_pos.z
	var x2 = glo_pos.x
	var y2 = glo_pos.y
	var z2 = glo_pos.z
	# we split the distance with different ratios q:p,
	# for example 0:4, 1:3, 2:2, 3:1, and 4:0, if divcount is 4
	for q in range(0, divcount + 1):
		var p = divcount - q
		var lw_instance = LightWall.instantiate()
		$Trails.add_child(lw_instance)
		lw_instance.Driver = Driver
		lw_instance.materials = Driver.TRAIL_MATERIALS
		#print($Trails.get_child_count())
		if $Trails.get_child_count() >= MAX_TRAILS:
			$Trails.get_child(0).free()
		lw_instance.set_global_position(
				Vector3(
				(p*x1 + q*x2) / divcount,
				(p*y1 + q*y2) / divcount, 
				(p*z1 + q*z2) / divcount
				)
		)
		#var mod_rot = $Player.get_last_rot()
		#mod_rot.y = mod_rot.y - PI
		#mod_rot.x = $Player.get_linear_velocity().angle_to(
				#$Player.get_linear_velocity() * Vector3(1, 0, 1)
		#)
		#lw_instance.set_global_rotation(mod_rot)
		lw_instance.set_global_rotation(Driver.get_last_rot())
		new_last_pos = Vector3(
				(p*x1 + q*x2) / divcount,
				(p*y1 + q*y2) / divcount,
				(p*z1 + q*z2) / divcount
		)
	Driver.set_last_pos(new_last_pos)
	Driver.set_last_rot(Driver.get_global_rotation())
