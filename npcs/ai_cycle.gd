extends VehicleBody3D


@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var Destruction = load("res://destruction/destruction.tscn")
@onready var destruction_instance = Destruction.instantiate()

var front_steer = 1
var engine_power = 400.0
var rear_steer = 0.0
var qt_available = true
var cycle_color = "pink"
var lw_color = "pink"
var lw_special = false
var alive = true
var explodable = true
var lw_active = false
var las_pos = Vector3.ZERO
var las_rot = Vector3.ZERO
var cam_active = false
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
	$Despawn.start()
func is_explodable():
	return explodable


func explode():
	alive = false
	explodable = false
	steering = 0
	engine_force = 0
	# i'm something of an animator myself
	if get_linear_velocity().length() < 30:
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


#botbot
func quickturn(dir):
	if not qt_available:
		return
	qt_available = false
	$QTCooldown.start()
	var directions = {
		"left":1,
		"right":-1,
	}
	var lin_vel = get_linear_velocity()
	set_linear_velocity(Vector3.ZERO)
	rotate_y(PI/2 * directions[dir])
	las_rot = get_global_rotation()
	cam_twist.rotate_y(PI/2 * -directions[dir])
	set_linear_velocity(-directions[dir] * Vector3(-lin_vel.z, 0, lin_vel.x))


#botbot
# head on = random 90 degree quickturn
# left or right, aling with lightwall
func avoid_lightwall(lin_vel):
	if $FRay.is_colliding():
		if randi_range(0, 1) == 0:
			quickturn("left")
		else:
			quickturn("right")
	elif $FLRay.is_colliding():
		var angle_to_normal = lin_vel.angle_to($FLRay.get_collision_normal())
		var rotate_angle = -1 * (angle_to_normal - PI/2)
		rotate_y(rotate_angle)
		set_linear_velocity(lin_vel.rotated(Vector3(0, 1, 0), rotate_angle))
	elif $FRRay.is_colliding():
		var angle_to_normal = lin_vel.angle_to($FRRay.get_collision_normal())
		var rotate_angle = angle_to_normal - PI/2
		rotate_y(rotate_angle)
		set_linear_velocity(lin_vel.rotated(Vector3(0, 1, 0), rotate_angle))


func _ready():
	las_pos = get_global_position()
	las_rot = get_global_rotation()


func _process(_delta):
	if cam_active:
		cam_twist.rotate_y(twist_input)
		cam_pitch.rotate_x(pitch_input)
		cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
		twist_input = 0
		pitch_input = 0
		
	#botbot
	var lin_vel = get_linear_velocity()
	var xz_lin_vel = lin_vel * Vector3(1, 0, 1)
	
	if lin_vel.length() < 100:
		engine_force = 400
	else:
		engine_force = 0
		
	# stuff below is only for the living 
	if not is_alive():
		return
	
	if xz_lin_vel.length() > 80:
		if $ImpactRay.is_colliding():
			explode()
	
	var kill_speed = 3
	if xz_lin_vel.length() < kill_speed:
		if $Kill.is_stopped():
			$Kill.start()
	else:
		if not $Kill.is_stopped():
			$Kill.stop()
	
	if (lin_vel * Vector3(1, 0, 1)).length() > 50:
		lw_active = true
	elif (lin_vel * Vector3(1, 0, 1)).length() < 15:
		lw_active = false
	if las_pos.distance_to(get_global_position()) >= 0.6:
		if lw_active:
			SignalBus.spawn_lw.emit(self)
		else:
			las_pos = get_global_position()
			las_rot = get_global_rotation()
	
	
	# -- BEGIN STEERING -- #
	#botbot
	avoid_lightwall(lin_vel)
	
	# -- END STEERING -- #


func _unhandled_input(event):
	if event is InputEventMouseMotion and cam_active:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_kill_timeout() -> void:
	explode()


func _on_qt_cooldown_timeout() -> void:
	qt_available = true


func _on_despawn_timeout() -> void:
	queue_free()
