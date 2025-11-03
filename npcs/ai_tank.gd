extends TankBase

# ai specific
var enemy := false
var targeting := true
var move_mode := "hunt"
var main_shot := "cannon1"
var sub_shot := "machinegun1"
var max_targeting_dist := 150.0
var max_firing_dist := 80.0
var ai_cooldown_mult := 1.5
var ai_damage_mult := 0.8

@onready var nav_agent = $NavAgent
@onready var path_target_tracker = $PathTargetTracker



func _ready():
	max_speed = 30.0
	max_ef = 300.0
	max_hp = 5000.0
	hp = 5000.0


func _physics_process(delta):
	
	#region Materials
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
	#endregion
	
	if dead:
		return
	
	var player_instance = level_instance.players[0]
	var player_location
	var player_targetable
	var player_aim_target_pos
	var player_aim_target_distance
	if player_instance:
		player_location = player_instance.global_position
		player_targetable = player_instance.targetable
		player_aim_target_pos = player_instance.get_node("Target").global_position
		player_aim_target_distance = player_aim_target_pos.distance_to(global_position)
	  
	#region GunControl
	if targeting and player_location:
		if player_aim_target_distance > max_targeting_dist:
			pass
		else:
			turret_twist.look_at(player_aim_target_pos)
			#$GunTargetTracker.look_at(player_location)
			#turret_twist.rotation = turret_twist.rotation.lerp($GunTargetTracker.rotation, delta * 5.0)
			# do this better!
			$TurretBaseCol.global_position = turret_pitch.get_child(0).global_position
			$TurretBaseCol.global_rotation = turret_pitch.get_child(0).global_rotation
			$TurretBarrelCol.global_position = turret_pitch.get_child(0).get_child(0).global_position
			$TurretBarrelCol.global_rotation = turret_pitch.get_child(0).get_child(0).global_rotation
			if player_targetable:
				shoot(main_shot)
	#endregion
	
	#region Steering
	if move_mode == "hunt" and player_location != null:
		nav_agent.target_position = player_location
		path_target_tracker.look_at(nav_agent.get_next_path_position())
		var tracker_y_delta = path_target_tracker.rotation_degrees.y
		engine_force = 400
		if get_linear_velocity().length() > max_speed:
			engine_force = 0
		if nav_agent.distance_to_target() < 40.0:
			if get_linear_velocity().length() > 10:
				engine_force = clamp(nav_agent.distance_to_target() * -20, -400, 0)
			else:
				engine_force = 0
		if tracker_y_delta < 0:
			angular_velocity = Vector3(0, -PI/3, 0)
		if tracker_y_delta > 0:
			angular_velocity = Vector3(0, PI/3, 0)
	elif move_mode == "patrol":
		pass
	else:
		pass
	#endregion

 
#overwrite
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
	$ShotCooldown.start(1.0 / shot_params["rof"] * ai_cooldown_mult)
	$Shot.play()
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,1) * 0.5)
	await get_tree().create_timer(0.1).timeout
	turret_barrel.transform = turret_barrel.transform.translated_local(Vector3(0,0,-1) * 0.5)
	$TurretBarrelCol.transform = $TurretBarrelCol.transform.translated_local(Vector3(0,0,-1) * 0.5)


#overwrite
func receive_health(source):
	if source == "god":
		hp = 5000.0
	else:
		pass
	hp = clamp(0.0, hp, max_hp)


#overwrite
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


func _on_nav_agent_navigation_finished() -> void:
	if move_mode == "hunt":
		move_mode = "still"
		await get_tree().create_timer(randf_range(1.0, 2.0)).timeout
		move_mode = "hunt"
