extends VehicleBody3D


var shot_available := true
var tank_color := "blue"
var shot_color := "blue"
var material_applied := false
var max_speed := 70.0
var max_ef := 300.0
var muzzle_vel := 200.0
var hp := 5000.0
var dead := false
var explodable := true
var controllable := false
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
@onready var TankDestruction = load("res://destruction/tank_destruction.tscn")
@onready var tank_destruction_instance = TankDestruction.instantiate()


func _ready():
	$Spawn.play()
	$SpawnTimer.start()
	
func _process(delta):
	
	#region MaterialManipulation
	if material_applied:
		var points_to_pass = []
		for d_dot in $DamageDots.get_children():
			points_to_pass.append(d_dot.get_global_position())
		$Tankbody.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
		
	if get_parent().get_node("Recognizers").get_child_count() > 0:
		var closest_rec_pos
		var closest_distance := 1_000_000.0
		for rec in get_parent().get_node("Recognizers").get_children():
			if rec.global_position.distance_to(global_position) < closest_distance:
				closest_rec_pos = rec.global_position
				closest_distance = rec.global_position.distance_to(global_position)
		turret_base.get_surface_override_material(1).set_shader_parameter("enemy_pos", closest_rec_pos)
		
		
	#endregion


	cam_twist.rotate_y(twist_input)
	cam_pitch.rotate_x(pitch_input)
	cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	
	if not controllable:
		return

	#region GunControl
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
	#endregion
	
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
	if get_linear_velocity().length() > max_speed:
			engine_force = 0
	if Input.is_action_pressed("steerleft"):
		# i fucking hate that this works better
		#rotate_y(delta * PI/4)
		angular_velocity = Vector3(0, PI/3, 0)
		#$BackLeft.engine_force = -max_ef
		#$FrontLeft.engine_force = -max_ef
		#$BackRight.engine_force = max_ef
		#$FrontRight.engine_force = max_ef
	if Input.is_action_pressed("steerright"):
		angular_velocity = Vector3(0, -PI/3, 0)
	#endregion
	
	if Input.is_action_pressed("light_attack"):
		shoot()
	


func shoot():
	if not shot_available:
		return
	shot_available = false
	var tankshot_instance = RBTankShot.instantiate()
	tankshot_instance.shot_color = shot_color
	tankshot_instance.gunner = self
	tankshot_instance.damage = 200.0
	tankshot_instance.apply_materials()
	level_instance.add_child(tankshot_instance)
	tankshot_instance.global_position = muzzle_point.global_position
	tankshot_instance.global_rotation = muzzle_point.global_rotation
	tankshot_instance.apply_central_impulse(
			-1 * tankshot_instance.global_basis.z * muzzle_vel + get_linear_velocity()
	)
	$ShotCooldown.start()
	$Shot.play()
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


func explode():
	if not explodable:
		return
	explodable = false
	$TurretTwist/TurretPitch/Turretbase.hide()
	$TurretBaseCol.queue_free()
	$TurretBarrelCol.queue_free()
	$Explode.play()
	get_parent().add_child(tank_destruction_instance)
	tank_destruction_instance.global_position = global_position
	tank_destruction_instance.tank_color = tank_color
	tank_destruction_instance.prepare()
	# turret debris
	tank_destruction_instance.get_child(0).apply_impulse(
			Vector3(
				randi_range(-5, 5),
				randi_range(5, 10),
				randi_range(-5, 5)
			)
	)
	# cubes
	for child in tank_destruction_instance.get_child(1).get_children():
			child.apply_impulse(
					Vector3(
						randi_range(-10, 10),
						randi_range(10, 20),
						randi_range(-10, 10)
					)
			)


func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		# so everything has time to stop before explosion frees collision
		await get_tree().create_timer(0.15).timeout
		SignalBus.player_became_untargetable.emit()
		explode()


func take_hit(shot_pos, dmg_value):
	if $DamageDots.get_child_count() < 200:
		var damage_dot = Node3D.new()
		$DamageDots.add_child(damage_dot)
		damage_dot.set_global_position(shot_pos)
	take_dmg(dmg_value)
	$Hit.play()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true


func _on_spawn_timer_timeout() -> void:
	$CamTwist/CamPitch/SpringArm3D/Camera3D.current = true
	controllable = true
	SignalBus.player_became_targetable.emit()
