extends VehicleBody3D


var shot_available := true
var cycle_color := "blue"
var lw_color := "blue"
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var level_instance: Node3D

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var turret_twist = $TurretTwist
@onready var turret_pitch = $TurretTwist/TurretPitch
@onready var muzzle_point = $TurretTwist/TurretPitch/Turretbase/Turretbarrel/MuzzlePoint
@onready var TankShot = load("res://destruction/tank_shot.tscn")

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
				Input.get_axis("gasdown", "gasup") * 400, -200, 500
	)
	$BackRight.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -200, 500
	)
	$FrontLeft.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -200, 500
	)
	$FrontRight.engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * 400, -200, 500
	)
	if Input.is_action_pressed("steerleft"):
		$BackLeft.engine_force = -300
		$FrontLeft.engine_force = -300
		$BackRight.engine_force = 300
		$FrontRight.engine_force = 300
	if Input.is_action_pressed("steerright"):
		$BackRight.engine_force = -300
		$FrontRight.engine_force = -300
		$BackLeft.engine_force = 300
		$FrontLeft.engine_force = 300
	#endregion
	
	if Input.is_action_pressed("light_attack"):
		if shot_available:
			shoot()
	
	

func shoot():
	shot_available = false
	var tankhshot_instance = TankShot.instantiate()
	tankhshot_instance.cycle_color = cycle_color
	tankhshot_instance.apply_materials()
	level_instance.add_child(tankhshot_instance)
	tankhshot_instance.global_position = muzzle_point.global_position
	tankhshot_instance.global_rotation = muzzle_point.global_rotation
	$ShotCooldown.start()


func apply_materials():
	var lc_materials = MaterialsBus.LC_STYLES
	$Tankbody.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$Tankbody.set_surface_override_material(1, lc_materials[cycle_color]["lwbase"])
	$Tankbody.set_surface_override_material(2, lc_materials[cycle_color]["lwbase"])
	$TurretTwist/TurretPitch/Turretbase.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$TurretTwist/TurretPitch/Turretbase/Turretbarrel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$TurretTwist/TurretPitch/Turretbase/Turretbarrel.set_surface_override_material(1, lc_materials[cycle_color]["lwbase"])


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true
