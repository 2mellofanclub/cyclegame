extends TankBase

# player specific 
var controllable := false
var targetable := true
var godmode := false

@onready var gun_cam = $TurretTwist/TurretPitch/SpringArm3D/Camera3D


func _ready():
	$Spawn.play()
	$SpawnTimer.start()
	SignalBus.ai_just_fuckkin_died.connect(receive_health)
	$HUD.update_hp(hp, max_hp)


func _physics_process(delta):

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


#overwrite
func receive_health(source):
	if source == "enemy":
		hp = max_hp
		for child in $DamageDots.get_children():
			child.queue_free()
	else:
		# heal
		# remove random DamageDots proportional to heal
		pass
	hp = clamp(0.0, hp, max_hp)
	$HUD.update_hp(hp, max_hp)


#overwrite
func take_dmg(dmg_value):
	if hp <= 0 or godmode:
		return
	hp -= float(dmg_value)
	hp = clamp(0.0, hp, max_hp)
	$HUD.update_hp(hp, max_hp)
	if hp <= 0:
		dead = true
		controllable = false
		engine_force = 0
		# so everything has time to stop before explosion frees collision
		await get_tree().create_timer(0.15).timeout
		targetable = false
		SignalBus.player_just_fuckkin_died.emit()
		explode()


func _on_spawn_timer_timeout() -> void:
	gun_cam.make_current()
	await get_tree().create_timer(0.2).timeout
	controllable = true
	targetable = true
