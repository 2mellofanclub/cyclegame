extends VehicleBody3D


var front_steer = 1
var engine_power = 400.0
var rear_steer = 0.0
var trail_materials = {
	"body":"res://materials/badguy_black1.tres",
	"wheelwells":"res://materials/lw_green1.tres",
	"lwbase":"res://materials/lw_green1.tres",
	"lwpulse":"res://materials/lw_green1_pulse.tres",
}
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
func is_explodable():
	return explodable

func kill():
	alive = false
func explode():
	kill()
	steering = 0
	engine_force = 0
	# i'm something of an animator myself
	if get_linear_velocity().length() < 50:
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
		var Destruction = load("res://destruction/destruction_blue.tscn")
		var destruction_instance = Destruction.instantiate()
		add_child(destruction_instance)
		set_linear_velocity(Vector3.ZERO)
		$lightcycle/Frontwheel.hide()
		$FrontRight/OmniLight3D2.hide()
		$lightcycle/Body.hide()
		$lightcycle/Rearwheel.hide()
		$BackRight/OmniLight3D.hide()
		for child in destruction_instance.get_children():
			child.apply_impulse(Vector3(
					randi_range(-10, 10),
					randi_range(10, 30),
					randi_range(-10, 10)
			))
		await get_tree().create_timer(4).timeout
		destruction_instance.queue_free()
	print("boom")
	

#botbot
func quickturn(dir):
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




@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
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
	
	var lin_vel = get_linear_velocity()
	#botbot
	if lin_vel.length() < 100:
		engine_force = 400
	else:
		engine_force = 0
		
	# stuff below is only for the living 
	if not is_alive():
		return
	
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
	
	# -- END STEERING -- #


func _unhandled_input(event):
	if event is InputEventMouseMotion and cam_active:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_kill_timeout() -> void:
	queue_free() # Replace with function body.
