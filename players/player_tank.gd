extends VehicleBody3D


var level_instance : Node3D
var shot_available := true
var tank_color := "blue"
var shot_color := "blue"
var shot_lin_vel_mult := 0.2
var shot_types = ShotBus.SHOT_TYPES
var materials_applied := false
var max_speed := 70.0
var max_ef := 300.0
var max_hp := 5000.0
var hp := 5000.0
var dead := false
var explodable := true
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
# player specific 
var controllable := false
var godmode := true

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var free_cam = $CamTwist/CamPitch/SpringArm3D/Camera3D
@onready var turret_twist = $TurretTwist
@onready var turret_pitch = $TurretTwist/TurretPitch
@onready var gun_cam = $TurretTwist/TurretPitch/SpringArm3D/Camera3D
@onready var turret_base = $TurretTwist/TurretPitch/Turretbase
@onready var turret_barrel = $TurretTwist/TurretPitch/Turretbase/Turretbarrel
@onready var muzzle_point = $TurretTwist/TurretPitch/Turretbase/Turretbarrel/MuzzlePoint
@onready var RBTankShot = load("res://destruction/rb_tank_shot.tscn")
@onready var TankDestruction = load("res://destruction/tank_destruction.tscn")
@onready var tank_destruction_instance = TankDestruction.instantiate()


func _ready():
	$Spawn.play()
	$SpawnTimer.start()
	SignalBus.ai_just_fuckkin_died.connect(receive_health)
	
func _process(delta):

	#region MaterialManipulation
	if materials_applied:
		var points_to_pass = []
		for d_dot in $DamageDots.get_children():
			points_to_pass.append(Vector4(
					d_dot.get_global_position().x,
					d_dot.get_global_position().y,
					d_dot.get_global_position().z,
					d_dot.scale.x
			))
		$Tankbody.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
		turret_base.get_surface_override_material(1).set_shader_parameter(
				"enemy_pos", get_closest_living_pos(level_instance.recognizers)
		)
		turret_base.get_surface_override_material(2).set_shader_parameter(
				"enemy_pos", get_closest_living_pos(level_instance.enemies)
		) 
	#endregion


	#region CamControl
	if Input.is_action_just_pressed("freelook"):
		free_cam.make_current()
	if Input.is_action_just_released("freelook"):
		gun_cam.make_current()
		cam_twist.global_position = $CTDefaultPos.global_position
		cam_twist.global_rotation = $CTDefaultPos.global_rotation
		cam_pitch.global_position = $CPDefaultPos.global_position
		cam_pitch.global_rotation = $CPDefaultPos.global_rotation
	if Input.is_action_pressed("freelook"):
		cam_twist.rotate_y(twist_input)
		cam_pitch.rotate_x(pitch_input)
		cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	#endregion
	
	if not controllable:
		return

	#region GunControl
	if not Input.is_action_pressed("freelook"):
		turret_twist.rotate_y(twist_input)
		turret_pitch.rotate_x(pitch_input)
		turret_pitch.rotation.x = clamp(turret_pitch.rotation.x, -PI/9, PI/7)
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
		angular_velocity = Vector3(0, PI/3, 0)
	if Input.is_action_pressed("steerright"):
		angular_velocity = Vector3(0, -PI/3, 0)
	#endregion
	
	#region Attacks
	if Input.is_action_pressed("light_attack"):
		shoot("machinegun1")
	elif Input.is_action_pressed("heavy_attack"):
		shoot("cannon1")
	#endregion
	

func get_closest_living_pos(array):
	var closest_member_pos = Vector3(0.0, 9999.0, 0.0)
	if len(array) > 0:
		var closest_distance :=  99999.0
		for member in array:
			if not "dead" in member:
				continue
			if member.dead == true:
				continue
			if member.global_position.distance_to(global_position) < closest_distance:
				closest_member_pos = member.global_position
				closest_distance = member.global_position.distance_to(global_position)
	return closest_member_pos


func shoot(shot_type):
	if not shot_available:
		return
	shot_available = false
	var shot_params = shot_types[shot_type]
	for i in range(0, shot_params["bullet_count"]):
		var tankshot_instance = RBTankShot.instantiate()
		tankshot_instance.shot_color = shot_color
		tankshot_instance.gunner = self
		tankshot_instance.damage = shot_params["dmg"]
		tankshot_instance.ddot_rad = shot_params["ddot_rad"]
		tankshot_instance.mass = shot_params["bullet_mass"]
		tankshot_instance.apply_materials()
		level_instance.add_child(tankshot_instance)
		tankshot_instance.global_position = muzzle_point.global_position
		tankshot_instance.global_rotation = muzzle_point.global_rotation
		tankshot_instance.scale = shot_params["scale"]
		tankshot_instance.apply_central_impulse(
				-1 * tankshot_instance.global_basis.z 
				* shot_params["muzzle_force"] 
				+ shot_lin_vel_mult * get_linear_velocity()
		)
		var spread = shot_params["spread"]
		if spread > 0:
			tankshot_instance.apply_central_impulse(
					Vector3(
						randf_range(-spread, spread),
						randf_range(-spread, spread),
						randf_range(-spread, spread)
					)
			) 
		tankshot_instance.show()
	$ShotCooldown.start(1.0/shot_params["rof"])
	$Shot.play()
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,1) * 0.5)
	await get_tree().create_timer(0.1).timeout
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,-1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,-1) * 0.5)


func apply_materials():
	var tank_materials = MaterialsBus.TANK_STYLES
	$Tankbody.set_surface_override_material(0, tank_materials[tank_color]["body0"].duplicate())
	$Tankbody.set_surface_override_material(1, tank_materials[tank_color]["tracks"])
	$Tankbody.set_surface_override_material(2, tank_materials[tank_color]["pit"])
	$Tankbody/Lattice.set_surface_override_material(0, tank_materials[tank_color]["lattice"])
	turret_base.set_surface_override_material(0, tank_materials[tank_color]["turret"])
	turret_base.set_surface_override_material(1, tank_materials[tank_color]["upper_radar"])
	turret_base.set_surface_override_material(2, tank_materials[tank_color]["lower_radar"])
	turret_barrel.set_surface_override_material(0, tank_materials[tank_color]["barrel"])
	turret_barrel.set_surface_override_material(1, tank_materials[tank_color]["muzzle"])
	materials_applied = true


func receive_health(source):
	if source == "enemy":
		hp = max_hp
		for child in $DamageDots.get_children():
			child.queue_free()
	else:
		pass
	hp = clamp(0.0, hp, max_hp)


func take_hit(shot_pos, dmg_value, ddot_rad):
	if $DamageDots.get_child_count() < 200:
		var damage_dot = Node3D.new()
		$DamageDots.add_child(damage_dot)
		damage_dot.set_global_position(shot_pos)
		damage_dot.scale = Vector3(ddot_rad, ddot_rad, ddot_rad)
	take_dmg(dmg_value)
	$Hit.play()


func take_dmg(dmg_value):
	if hp <= 0 or godmode:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		engine_force = 0
		# so everything has time to stop before explosion frees collision
		await get_tree().create_timer(0.15).timeout
		SignalBus.player_became_untargetable.emit()
		SignalBus.player_just_fuckkin_died.emit()
		explode()


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
	apply_impulse(
			Vector3(
				randi_range(-10, 10),
				randi_range(40, 50),
				randi_range(-10, 10)
			)
	)
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


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true


func _on_spawn_timer_timeout() -> void:
	gun_cam.make_current()
	await get_tree().create_timer(0.2).timeout
	controllable = true
	SignalBus.player_became_targetable.emit()
