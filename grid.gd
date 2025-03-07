extends Node3D

const MAX_TRAILS = 6000

@onready var LightWall = preload("res://objects/lightwallseg.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SOS.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# i knew shit was gonna be like this when i mess with vectors
# godmman
func _on_player_spawn_lw():
	var las_pos = $Player.get_last_pos()
	var glo_pos = $Player.get_global_position()
	# updated every loop, but only last value used
	var new_last_pos = Vector3.ZERO
	# revealed to this function in a dream 
	# since lightwall hasn't been instantiated
	var lw_width = 0.3
	var distance = (las_pos).distance_to(glo_pos)
	var divcount = ceil(distance / lw_width)
	var x1 = las_pos.x
	var y1 = las_pos.y
	var z1 = las_pos.z
	var x2 = glo_pos.x
	var y2 = glo_pos.y
	var z2 = glo_pos.z
	
	# we split the distance with different ratios q:p,
	# for example 1:3, 2:2, and 3:1, if divcount is 4
	for q in range(1, divcount):
		var p = divcount - q
		var lw_instance = LightWall.instantiate()
		$Trails.add_child(lw_instance)
		lw_instance.Player = $Player
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
		lw_instance.set_global_rotation($Player.get_last_rot())
		new_last_pos = Vector3(
				(p*x1 + q*x2) / divcount,
				(p*y1 + q*y2) / divcount,
				(p*z1 + q*z2) / divcount
		)
	$Player.set_last_pos(new_last_pos)
	$Player.set_last_rot($Player.get_global_rotation())
