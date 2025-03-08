extends VehicleBody3D


var FRONT_STEER = 1
var ENGINE_POWER = 400.0
var REAR_STEER = 0.0
var materials = {
	"body":"res://materials/badguy_black1.tres",
	"wheelwells":"res://materials/lw_green1.tres",
	"lwbase":"res://materials/lw_green1.tres",
	"lwpulse":"res://materials/lw_green1_pulse.tres",
	"lattice":"res://materials/lw_green1.tres",
}
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
	# i'm something of an animator myself
	if get_linear_velocity().length() < 30:
		set_linear_velocity(Vector3.ZERO)
		$NotPositive.play()
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
		var Destruction = load("res://destruction/destruction.tscn")
		var destruction_instance = Destruction.instantiate()
		add_child(destruction_instance)
		for child in $lightcycle.get_children():
			child.hide()
		$FrontRight/OmniLight3D2.hide()
		$BackRight/OmniLight3D.hide()
		destruction_instance.materials = materials
		destruction_instance.prepare()
		for child in destruction_instance.get_children():
			child.apply_impulse(Vector3(
					randi_range(-10, 10),
					randi_range(20, 30),
					randi_range(-10, 10)
			) + last_lin_vel*0.3)
		await get_tree().create_timer(13).timeout
		destruction_instance.queue_free()
	print("boom")


func apply_materials():
	$lightcycle/Body.set_surface_override_material(0, load(materials["body"]))
	$lightcycle/Body/Windshield_001.set_surface_override_material(0, load(materials["body"]))
	$lightcycle/Rearwheel.set_surface_override_material(0, load(materials["body"]))
	$lightcycle/Rearwheel.set_surface_override_material(1, load(materials["wheelwells"]))
	$lightcycle/Frontwheel.set_surface_override_material(0, load(materials["body"]))
	$lightcycle/Frontwheel.set_surface_override_material(1, load(materials["wheelwells"]))


#botbot
func quickturn(n):
	if not alive:
		return
	var lin_vel = get_linear_velocity()
	set_linear_velocity(Vector3.ZERO)
	rotate_y(PI/2*n)
	las_rot = get_global_rotation()
	cam_twist.rotate_y(-n*PI/2)
	set_linear_velocity(-n*Vector3(-lin_vel.z, 0, lin_vel.x))




@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
func _ready():
	las_pos = get_global_position()
	las_rot = get_global_rotation()


func _process(_delta):
	#cam_twist.rotate_y(twist_input)
	#cam_pitch.rotate_x(pitch_input)
	#cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	#twist_input = 0
	#pitch_input = 0
	
	#botbot
	if get_linear_velocity().length() < 100:
		engine_force = 400
	else:
		engine_force = 0
		
	# stuff below is only for the living 
	if not is_alive():
		return
	
	if (get_linear_velocity()*Vector3(1, 0, 1)).length() > 50:
		lw_active = true
	elif (get_linear_velocity()*Vector3(1, 0, 1)).length() < 15:
		lw_active = false
	if las_pos.distance_to(get_global_position()) >= 0.6:
		if lw_active:
			SignalBus.spawn_lw.emit(self)
		else:
			las_pos = get_global_position()
			las_rot = get_global_rotation()
	
	
	# -- BEGIN STEERING -- #
	#if not Input.is_action_pressed("superbrake"):
		#steering = Input.get_axis("steerright", "steerleft") * FRONT_STEER
		#$BackLeft.steering = REAR_STEER * steering
		#$BackRight.steering = REAR_STEER * steering
		#engine_force = clamp(
				#Input.get_axis("gasdown", "gasup") * ENGINE_POWER, -200, 500
		#)
		#$lightcycle.global_rotation.z = (global_rotation.z + 
				#Input.get_axis("steerright", "steerleft") * PI/6
		#)
		## Quickturn left with speed intact
		#if Input.is_action_just_pressed("ninleft"):
			#var lin_vel = get_linear_velocity()
			#set_linear_velocity(Vector3.ZERO)
			#rotate_y(PI/2)
			#las_rot = get_global_rotation()
			#cam_twist.rotate_y(-PI/2)
			#set_linear_velocity(-Vector3(-lin_vel.z, 0, lin_vel.x))
		## Quickturn right with speed intact
		#if Input.is_action_just_pressed("ninright"):
			#var lin_vel = get_linear_velocity()
			#set_linear_velocity(Vector3.ZERO)
			#rotate_y(-PI/2)
			#las_rot = get_global_rotation()
			#cam_twist.rotate_y(PI/2)
			#set_linear_velocity(Vector3(-lin_vel.z, 0, lin_vel.x))
	#if Input.is_action_just_pressed("superbrake"):
		#$lightcycle.rotate_y(PI/2)
		#$lightcycle.rotate_x(PI/6)
		#set_brake(10)
	#if Input.is_action_just_released("superbrake"):
		#$lightcycle.rotate_y(-PI/2)
		#set_brake(0)
	# -- END STEERING -- #


#func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#twist_input = -1 * event.relative.x * mouse_sens
			#pitch_input = -1 * event.relative.y * mouse_sens


func _on_kill_timeout() -> void:
	queue_free() # Replace with function body.
