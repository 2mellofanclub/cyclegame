extends Node3D


const MAX_TRAILS = 5000


@onready var LightWall = preload("res://objects/lightwallseg.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.spawn_lw.connect(spawn_lw) 
	$SOS.play()


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# i knew shit was gonna be like this when i mess with vectors
# godmman
func spawn_lw(Driver):
	var las_pos = Driver.get_last_pos()
	var glo_pos = Driver.get_global_position()
	# revealed to this function in a dream 
	# since lightwall hasn't been instantiated
	var lw_width = 0.6
	var distance = (las_pos).distance_to(glo_pos)
	var x1 = las_pos.x
	var y1 = las_pos.y
	var z1 = las_pos.z
	var x2 = glo_pos.x
	var y2 = glo_pos.y
	var z2 = glo_pos.z
	var lw_instance = LightWall.instantiate()
	$Trails.add_child(lw_instance)
	lw_instance.Driver = Driver
	lw_instance.materials = Driver.TRAIL_MATERIALS
	if $Trails.get_child_count() >= MAX_TRAILS:
		$Trails.get_child(0).free()
	lw_instance.set_global_position(Vector3(
			(x1 + x2)/2,
			(y1 + y2)/2,
			(z1 + z2)/2
	))
	lw_instance.set_global_rotation(Driver.get_last_rot())
	lw_instance.scale_object_local(Vector3(1, 1, distance/lw_width))
	Driver.set_last_pos(glo_pos)
	Driver.set_last_rot(Driver.get_global_rotation())


#botbot
func _on_bot_turn_left_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn(1)
func _on_bot_turn_right_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn(-1)
