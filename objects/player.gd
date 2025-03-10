extends VehicleBody3D


@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var Destruction = load("res://destruction/destruction.tscn")
@onready var destruction_instance = Destruction.instantiate()

var front_steer = 1
var engine_power = 400.0
var rear_steer = 0.0
var cycle_color = "blue"
var lw_color = "blue"
var lw_special = false
var alive = true
var explodable = true
var lw_active = false
var las_pos = Vector3.ZERO
var las_rot = Vector3.ZERO
var mouse_sens = 0.001
var twist_input = 0.0
var pitch_input = 0.0


func get_last_pos():
	return las_pos
func get_last_rot():
	return las_rot
func set_last_pos(pos: Vector3):
	las_pos = pos
func set_last_rot(rot: Vector3):
	las_rot = rot
func is_alive():
	return alive
func kill():
	alive = false
func is_explodable():
	return explodable


func explode():
	alive = false
	explodable = false
	steering = 0
	engine_force = 0
	$IDunno/TrailEater.translate(Vector3(0, 100, 0))
	# i'm something of an animator myself
	if get_linear_velocity().length() < 3:
		set_linear_velocity(Vector3.ZERO)
		#$Sounds/Splash.play()
		$lightcycle/Frontwheel.hide()
		$FrontRight/OmniLight3D2.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Body.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Rearwheel.hide()
		$BackRight/OmniLight3D.hide()
	else:
		var last_lin_vel = get_linear_velocity()
		set_linear_velocity(Vector3.ZERO)
		#$Sounds/Splash.play()
		add_child(destruction_instance)
		for child in $lightcycle.get_children():
			child.hide()
		$FrontRight/OmniLight3D2.hide()
		$BackRight/OmniLight3D.hide()
		destruction_instance.cycle_color = cycle_color
		destruction_instance.prepare()
		for child in destruction_instance.get_children():
			child.apply_impulse(Vector3(
					randi_range(-10, 10),
					randi_range(20, 30),
					randi_range(-10, 10)
			) + last_lin_vel * 0.3)
		await get_tree().create_timer(13).timeout
		destruction_instance.queue_free()
	print("boom")


func apply_materials():
	var lc_materials = MaterialsBus.LC_MATERIALS
	$lightcycle/Body.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Body.set_surface_override_material(1, lc_materials[cycle_color]["body1"])
	$lightcycle/Body/Windshield_001.set_surface_override_material(0, lc_materials[cycle_color]["body1"])
	$lightcycle/Rearwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Rearwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])
	$lightcycle/Frontwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Frontwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])




func _ready():
	las_pos = global_position
	las_rot = global_rotation


func _process(delta):
	var lin_vel = get_linear_velocity()
	var xz_lin_vel = lin_vel * Vector3(1, 0, 1)
	
	cam_twist.rotate_y(twist_input)
	cam_pitch.rotate_x(pitch_input)
	cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	twist_input = 0
	pitch_input = 0
	
	# stuff below is only for the living 
	if not is_alive():
		return
	
	if (xz_lin_vel).length() > 80:
		if $ImpactRay.is_colliding():
			explode()
	
	var kill_speed = 3
	if xz_lin_vel.length() < kill_speed:
		if $Kill.is_stopped():
			$Kill.start()
	else:
		if not $Kill.is_stopped():
			$Kill.stop()
	
	if (xz_lin_vel).length() > 50:
		lw_active = true
	elif (xz_lin_vel).length() < 15:
		lw_active = false
	if las_pos.distance_to(get_global_position()) >= 0.6:
		if lw_active:
			SignalBus.spawn_lw.emit(self)
		else:
			las_pos = global_position
			las_rot = global_rotation

	$lightcycle/Rearwheel.rotate_object_local(
			Vector3(1, 0, 0), 
			(2 * PI) * ($BackLeft.get_rpm() / 60 * delta)
	)
	$lightcycle/Frontwheel.rotate_object_local(
			Vector3(1, 0, 0), 
			(2 * PI) * ($FrontLeft.get_rpm() / 60 * delta)
	)

	# -- BEGIN STEERING -- #
	if not Input.is_action_pressed("superbrake"):
		steering = Input.get_axis("steerright", "steerleft") * front_steer
		$BackLeft.steering = rear_steer * steering
		$BackRight.steering = rear_steer * steering
		engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * engine_power, -200, 500
		)
		if lin_vel.length() > 100:
			engine_force = 0
		$lightcycle.global_rotation.z = (global_rotation.z + 
				Input.get_axis("steerright", "steerleft") * PI/6
		)
		# Quickturn left with speed intact
		if Input.is_action_just_pressed("ninleft"):
			set_linear_velocity(Vector3.ZERO)
			rotate_y(PI/2)
			las_rot = global_rotation
			cam_twist.rotate_y(-PI/2)
			set_linear_velocity(-Vector3(-lin_vel.z, 0, lin_vel.x))
		# Quickturn right with speed intact
		if Input.is_action_just_pressed("ninright"):
			set_linear_velocity(Vector3.ZERO)
			rotate_y(-PI/2)
			las_rot = global_rotation
			cam_twist.rotate_y(PI/2)
			set_linear_velocity(Vector3(-lin_vel.z, 0, lin_vel.x))
	if Input.is_action_just_pressed("superbrake"):
		$lightcycle.rotate_y(PI/2)
		$IDunno.rotate_y(PI/2)
		$lightcycle.rotate_x(PI/6)
		set_brake(10)
	if Input.is_action_just_released("superbrake"):
		$lightcycle.rotate_y(-PI/2)
		$IDunno.rotate_y(-PI/2)
		set_brake(0)
	# -- END STEERING -- #


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_kill_timeout() -> void:
	explode()
