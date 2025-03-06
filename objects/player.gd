extends VehicleBody3D

const MAX_STEER = 1
const ENGINE_POWER = 400
signal spawn_lw

var ALIVE = true
var EXPLODABLE = true
var LW_ACTIVE = false
var LAST_POS = Vector3.ZERO
var LAST_ROT = Vector3.ZERO
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0


func get_last_pos():
	return LAST_POS
func get_last_rot():
	return LAST_ROT
func set_last_pos(pos: Vector3):
	LAST_POS = pos
func set_last_rot(rot: Vector3):
	LAST_ROT = rot
func is_alive():
	return ALIVE
func is_explodable():
	return EXPLODABLE
	
func explode():
	ALIVE = false
	steering = 0
	engine_force = 0
	# i'm something of an animator myself
	set_linear_velocity(Vector3.ZERO)
	$notpositive.play()
	$lightcycle/Frontwheel.hide()
	$frontright/OmniLight3D2.hide()
	await get_tree().create_timer(0.1).timeout
	$lightcycle/Body.hide()
	await get_tree().create_timer(0.1).timeout
	$lightcycle/Rearwheel.hide()
	$backright/OmniLight3D.hide()
	print("boom")
	


@onready var camtwist = $camtwist
@onready var campitch = $camtwist/campitch
func _ready():
	LAST_POS = get_global_position()
	LAST_ROT = get_global_rotation()

func _process(delta):
	camtwist.rotate_y(twist_input)
	campitch.rotate_x(pitch_input)
	campitch.rotation.x = clamp(campitch.rotation.x, -1, 0.5)
	twist_input = 0
	pitch_input = 0
	
	# stuff below is only for the living 
	if not ALIVE:
		return
	
	
	if (get_linear_velocity()*Vector3(1,0,1)).length() > 50:
		LW_ACTIVE = true
	elif (get_linear_velocity()*Vector3(1,0,1)).length() < 15:
		LW_ACTIVE = false
	if LAST_POS.distance_to(get_global_position()) >= 3:
		if LW_ACTIVE:
			spawn_lw.emit()
		else:
			LAST_POS = get_global_position()
			LAST_ROT = get_global_rotation()
	
	# -- BEGIN STEERING -- #
	if not Input.is_action_pressed("superbrake"):
		steering = Input.get_axis("steerright","steerleft") * MAX_STEER
		$backleft.steering = -0.2 * steering
		$backright.steering = -0.2 * steering
		engine_force = clamp(Input.get_axis("gasdown", "gasup") * ENGINE_POWER, -200, 500)
		$lightcycle.global_rotation.z = Input.get_axis("steerright","steerleft") * 0.35
		# Quickturn left with speed intact
		if Input.is_action_just_pressed("ninleft"):
			var linvel = get_linear_velocity()
			set_linear_velocity(Vector3.ZERO)
			rotate_y(PI/2)
			camtwist.rotate_y(-PI/2)
			set_linear_velocity(-Vector3(-linvel.z,0,linvel.x))
		# Quickturn right with speed intact
		if Input.is_action_just_pressed("ninright"):
			var linvel = get_linear_velocity()
			set_linear_velocity(Vector3.ZERO)
			rotate_y(-PI/2)
			camtwist.rotate_y(PI/2)
			set_linear_velocity(Vector3(-linvel.z,0,linvel.x))
			#apply_impulse(transform.basis.z*-100)
	if Input.is_action_just_pressed("superbrake"):
		$lightcycle.rotate_y(PI/2)
		$lightcycle.rotate_x(PI/6)
		set_brake(10)
	if Input.is_action_just_released("superbrake"):
		$lightcycle.rotate_y(-PI/2)
		set_brake(0)
	# -- END STEERING -- #



func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens
