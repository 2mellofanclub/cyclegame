extends VehicleBody3D


var shot_available := true
var cycle_color := "blue"
var lw_color := "blue"
var max_ef := 300.0
var muzzle_vel := 200.0
var hp := 5000.0
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var level_instance: Node3D

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var turret_twist = $TurretTwist
@onready var turret_pitch = $TurretTwist/TurretPitch
@onready var turret_base = $TurretTwist/TurretPitch/Turretbase
@onready var turret_barrel = $TurretTwist/TurretPitch/Turretbase/Turretbarrel
@onready var muzzle_point = $TurretTwist/TurretPitch/Turretbase/Turretbarrel/MuzzlePoint
@onready var RBTankShot = load("res://destruction/rb_tank_shot.tscn")

func _ready():
	pass
	
func _process(delta):
	

	cam_twist.rotate_y(twist_input)
	cam_pitch.rotate_x(pitch_input)
	cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	if not Input.is_action_pressed("freelook"):
		turret_twist.rotate_y(twist_input)
		turret_pitch.rotate_x(pitch_input)
		turret_pitch.rotation.x = clamp(turret_pitch.rotation.x, -PI/8, PI/8)
	twist_input = 0
	pitch_input = 0
	# do this better!
	$TurretBaseCol.global_position = turret_pitch.get_child(0).global_position
	$TurretBaseCol.global_rotation = turret_pitch.get_child(0).global_rotation
	$TurretBarrelCol.global_position = turret_pitch.get_child(0).get_child(0).global_position
	$TurretBarrelCol.global_rotation = turret_pitch.get_child(0).get_child(0).global_rotation
	
	
	#region Steering
	$BackLeft.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -max_ef, max_ef
	)
	$BackRight.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -max_ef, max_ef
	)
	$FrontLeft.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -max_ef, max_ef
	)
	$FrontRight.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -max_ef, max_ef
	)
	if Input.is_action_pressed("steerleft"):
		$BackLeft.engine_force = -max_ef
		$FrontLeft.engine_force = -max_ef
		$BackRight.engine_force = max_ef
		$FrontRight.engine_force = max_ef
	if Input.is_action_pressed("steerright"):
		$BackRight.engine_force = -max_ef
		$FrontRight.engine_force = -max_ef
		$BackLeft.engine_force = max_ef
		$FrontLeft.engine_force = max_ef
	#endregion
	
	if Input.is_action_pressed("light_attack"):
		if shot_available:
			shoot(delta)
	
	

func shoot(delta):
	shot_available = false
	var tankshot_instance = RBTankShot.instantiate()
	tankshot_instance.cycle_color = cycle_color
	tankshot_instance.gunner = self
	tankshot_instance.apply_materials()
	level_instance.add_child(tankshot_instance)
	tankshot_instance.global_position = muzzle_point.global_position
	tankshot_instance.global_rotation = muzzle_point.global_rotation
	tankshot_instance.apply_central_impulse(
			-1 * tankshot_instance.global_basis.z * muzzle_vel + get_linear_velocity()
	)
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,1) * 0.5)
	await get_tree().create_timer(0.1).timeout
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,-1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,-1) * 0.5)
	$ShotCooldown.start()


func apply_materials():
	var lc_materials = MaterialsBus.LC_STYLES
	$Tankbody.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$Tankbody.set_surface_override_material(1, lc_materials[cycle_color]["lwbase"])
	$Tankbody.set_surface_override_material(2, lc_materials[cycle_color]["lwbase"])
	turret_base.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	turret_barrel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	turret_barrel.set_surface_override_material(1, lc_materials[cycle_color]["lwbase"])


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true
