extends VehicleBody3D


var shot_available := true
var tank_color := "blue"
var shot_color := "blue"
var material_applied := false
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
	if material_applied:
		var points_to_pass = []
		for d_dot in $DamageDots.get_children():
			points_to_pass.append(d_dot.get_global_position())
		$Tankbody.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
	
	
	#region CamAndGunControl
	#endregion
	
	
	#region Steering
	
	#endregion
	
	
	

func shoot(delta):
	shot_available = false
	var tankshot_instance = RBTankShot.instantiate()
	tankshot_instance.shot_color = shot_color
	tankshot_instance.gunner = self
	tankshot_instance.apply_materials()
	level_instance.add_child(tankshot_instance)
	tankshot_instance.global_position = muzzle_point.global_position
	tankshot_instance.global_rotation = muzzle_point.global_rotation
	tankshot_instance.apply_central_impulse(
			-1 * tankshot_instance.global_basis.z * muzzle_vel + get_linear_velocity()
	)
	$ShotCooldown.start()
	$TurretTwist/TurretPitch/Turretbase/Turretbarrel/MuzzlePoint/Shot.play()
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,1) * 0.5)
	await get_tree().create_timer(0.1).timeout
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,-1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,-1) * 0.5)


func apply_materials():
	var tank_materials = MaterialsBus.TANK_STYLES
	$Tankbody.set_surface_override_material(0, tank_materials[tank_color]["body0"])
	$Tankbody.set_surface_override_material(1, tank_materials[tank_color]["tracks"])
	$Tankbody.set_surface_override_material(2, tank_materials[tank_color]["pit"])
	$Tankbody/Lattice.set_surface_override_material(0, tank_materials[tank_color]["lattice"])
	turret_base.set_surface_override_material(0, tank_materials[tank_color]["turret"])
	turret_base.set_surface_override_material(1, tank_materials[tank_color]["upper_radar"])
	turret_base.set_surface_override_material(2, tank_materials[tank_color]["lower_radar"])
	turret_barrel.set_surface_override_material(0, tank_materials[tank_color]["barrel"])
	turret_barrel.set_surface_override_material(1, tank_materials[tank_color]["muzzle"])
	material_applied = true


func take_hit(shot_pos):
	if $DamageDots.get_child_count() < 200:
		var damage_dot = Node3D.new()
		$DamageDots.add_child(damage_dot)
		damage_dot.set_global_position(shot_pos)
	$Hit.play()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true
