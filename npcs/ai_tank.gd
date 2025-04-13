extends VehicleBody3D


var level_instance : Node3D
var shot_available := true
var tank_color := "blue"
var shot_color := "blue"
var shot_lin_vel_mult := 0.2
var shot_types = ShotBus.SHOT_TYPES
var materials_applied := false
var max_speed := 30.0
var max_ef := 300.0
var max_hp := 5000.0
var hp := 5000.0
var dead := false
var explodable := true
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
# ai specific
var enemy := false
var player_targetable := false
var targeting := true
var move_mode := "hunt"
var max_targeting_dist := 150.0
var max_firing_dist := 100.0

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var turret_twist = $TurretTwist
@onready var turret_pitch = $TurretTwist/TurretPitch
@onready var turret_base = $TurretTwist/TurretPitch/Turretbase
@onready var turret_barrel = $TurretTwist/TurretPitch/Turretbase/Turretbarrel
@onready var muzzle_point = $TurretTwist/TurretPitch/Turretbase/Turretbarrel/MuzzlePoint
@onready var nav_agent = $NavAgent
@onready var RBTankShot = load("res://destruction/rb_tank_shot.tscn")
@onready var TankDestruction = load("res://destruction/tank_destruction.tscn")
@onready var tank_destruction_instance = TankDestruction.instantiate()


func _ready():
	SignalBus.player_became_targetable.connect(allow_target_player)
	SignalBus.player_became_untargetable.connect(disallow_target_player)
	
	
func _process(delta):
	if materials_applied:
		var points_to_pass = []
		for d_dot in $DamageDots.get_children():
			points_to_pass.append(d_dot.get_global_position())
		$Tankbody.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
	
	if dead:
		return
		
	var player_location = level_instance.get_node_or_null("PlayerTank").global_position
	var player_distance = player_location.distance_to(global_position)
	
	#region GunControl
	if targeting:
		if not player_location:
			return
		if player_distance > max_targeting_dist:
			return
		turret_twist.look_at(player_location)
		#$GunTargetTracker.look_at(player_location)
		#turret_twist.rotation = turret_twist.rotation.lerp($GunTargetTracker.rotation, delta * 5.0)
		# do this better!
		$TurretBaseCol.global_position = turret_pitch.get_child(0).global_position
		$TurretBaseCol.global_rotation = turret_pitch.get_child(0).global_rotation
		$TurretBarrelCol.global_position = turret_pitch.get_child(0).get_child(0).global_position
		$TurretBarrelCol.global_rotation = turret_pitch.get_child(0).get_child(0).global_rotation
		if player_distance < max_firing_dist and player_targetable:
			shoot("cannon1")
	#endregion
	
	#region Steering
	if move_mode == "hunt":
		if player_location and player_distance > 15.0:
			nav_agent.target_position = player_location
			var direction = nav_agent.get_next_path_position() - global_position
			direction = direction.normalized()
			look_at(global_position + direction)
			global_position += direction * max_speed/2.0 * delta
	elif move_mode == "patrol":
		pass
	else:
		pass
	#endregion

func allow_target_player():
	player_targetable = true
func disallow_target_player():
	player_targetable = false


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
		tankshot_instance.apply_materials()
		level_instance.add_child(tankshot_instance)
		tankshot_instance.global_position = muzzle_point.global_position
		tankshot_instance.global_rotation = muzzle_point.global_rotation
		tankshot_instance.scale = shot_params["scale"]
		tankshot_instance.apply_central_impulse(
				-1 * tankshot_instance.global_basis.z 
				* shot_params["muzzle_vel"] 
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
	$Tankbody.set_surface_override_material(0, tank_materials[tank_color]["body0"])
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
	if source == "god":
		hp = 5000.0
	else:
		pass
	hp = clamp(0.0, hp, max_hp)


func take_hit(shot_pos, dmg_value):
	if $DamageDots.get_child_count() < 200:
		var damage_dot = Node3D.new()
		$DamageDots.add_child(damage_dot)
		damage_dot.set_global_position(shot_pos)
	take_dmg(dmg_value)
	$Hit.play()


func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		engine_force = 0
		if enemy:
			SignalBus.ai_just_fuckkin_died.emit("enemy")
		else:
			SignalBus.ai_just_fuckkin_died.emit("ally")
		# so everything has time to stop before explosion frees collision
		await get_tree().create_timer(0.15).timeout
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
				randi_range(400, 500),
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
						randi_range(-20, 20),
						randi_range(10, 20),
						randi_range(-20, 20)
					)
			)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_shot_cooldown_timeout() -> void:
	shot_available = true
