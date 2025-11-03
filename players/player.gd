extends PlayerBase

# player specific
var targetable = true
var qt_cam_inverter := 1.0
var disc_attack_available := true
var right_disc_out := false
var left_disc_out := false
var road_rash_side := ""

 
#func _ready():


func _physics_process(delta):
	var lin_vel = get_linear_velocity()
	var xz_lin_vel = lin_vel * Vector3(1, 0, 1)
	
	#region Cam
	if default_cam.current:
		cam_twist.rotate_y(twist_input)
		cam_pitch.rotate_x(pitch_input)
	cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
	twist_input = 0
	pitch_input = 0
	#endregion
	
	# stuff below is only for the living 
	if not controllable:
		return
		
	if (xz_lin_vel).length() > deadly_impact_th:
		if $ImpactRay.is_colliding():
			explode()
	if xz_lin_vel.length() < kill_speed:
		if $KillTimer.is_stopped():
			$KillTimer.start()
	else:	
		$KillTimer.stop()
	
	#region LW
	if (xz_lin_vel).length() > lw_on_th:
		lw_active = true
	elif (xz_lin_vel).length() < lw_off_th:
		lw_active = false
	if las_pos.distance_to(global_position) >= 0.5:
		if lw_active:
			spawn_lw()
		las_pos = global_position
		las_rot = global_rotation
		#endregion

	$lightcycle/Rearwheel.rotate_object_local(
			Vector3(1, 0, 0), 
			(2 * PI) * ($BackLeft.get_rpm() / 60 * delta)
	)
	$lightcycle/Frontwheel.rotate_object_local(
			Vector3(1, 0, 0), 
			(2 * PI) * ($FrontLeft.get_rpm() / 60 * delta)
	)
	
	#region Steering
	if not Input.is_action_pressed("superbrake"):
		steering = Input.get_axis("steerright", "steerleft") * front_steer
		$BackLeft.steering = rear_steer * steering
		$BackRight.steering = rear_steer * steering
		engine_force = clamp(
				Input.get_axis("gasdown", "gasup") * engine_power, -200, 500
		)
		if lin_vel.length() > max_speed:
			engine_force = 0
		
		$lightcycle.rotation.z = lerp(
				$lightcycle.rotation.z, 
				Input.get_axis("steerright", "steerleft") * PI/9, 
				0.1
		)
		$sapientblockman.rotation.z = lerp(
				$sapientblockman.rotation.z, 
				Input.get_axis("steerright", "steerleft") * PI/9, 
				0.1
		)
		# Quickturn left with speed intact
		if Input.is_action_just_pressed("ninleft"):
			player_quickturn("left", lin_vel)
		# Quickturn right with speed intact
		if Input.is_action_just_pressed("ninright"):
			player_quickturn("right", lin_vel)
	if Input.is_action_just_pressed("superbrake"):
		$lightcycle.rotate_y(PI/2)
		$IDunno.rotate_y(PI/2)
		$lightcycle.rotate_x(PI/6)
		set_brake(10)
	if Input.is_action_just_released("superbrake"):
		$lightcycle.rotate_y(-PI/2)
		$IDunno.rotate_y(-PI/2)
		set_brake(0)
	#endregion
	
	if Input.is_action_just_pressed("heavy_attack"):
		road_rash("right")
	if Input.is_action_just_pressed("light_attack"):
		road_rash("left")
	if Input.is_action_just_released("heavy_attack"):
		road_rash_recover("right")
	if Input.is_action_just_released("light_attack"):
		road_rash_recover("left")



func player_quickturn(dir, lin_vel):
	var old_vel = lin_vel
	var directions = {
		"left" : 1,
		"right" : -1,
	}
	set_linear_velocity(Vector3.ZERO)
	rotate_y(directions[dir] * PI/2)
	las_rot = global_rotation
	cam_twist.rotate_y(qt_cam_inverter * directions[dir] * -PI/2)
	set_linear_velocity(
			Vector3(
			old_vel.z * directions[dir],
			old_vel.y, 
			old_vel.x * -directions[dir]
			)
	)


# overwrite
func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		default_cam.make_current()
		SignalBus.player_became_untargetable.emit()
		SignalBus.player_just_fuckkin_died.emit()
		$sapientblockman.hide()
		explode()


func road_rash(side: String):
	if not disc_attack_available:
		return
	front_steer = 0.01
	match side:
		"left":
			disc_attack_available = false
			left_disc_out = true
			$AnimationPlayer.play("road_rash_left")
			$sapientblockman/DiscCamLeft.make_current()
			await get_tree().create_timer(0.4).timeout
			disc_back.hide()
			disc_left.show()
		"right":
			disc_attack_available = false
			right_disc_out = true
			$AnimationPlayer.play("road_rash_right")
			$sapientblockman/DiscCamRight.make_current()
			await get_tree().create_timer(0.4).timeout
			disc_back.hide()
			disc_right.show()


func road_rash_recover(side: String):
	front_steer = 1.0
	match side:
		"left":
			if not left_disc_out:
				return
			$AnimationPlayer.play("road_rash_left_back")
			$DiscAttackCooldown.start()
			default_cam.make_current()
			disc_left_sc.hitbox_active = false
			await get_tree().create_timer(0.5).timeout
			disc_left.hide()
			disc_back.show()
		"right":
			if not right_disc_out:
				return
			$AnimationPlayer.play("road_rash_right_back")
			$DiscAttackCooldown.start()
			default_cam.make_current()
			disc_right_sc.hitbox_active = false
			await get_tree().create_timer(0.5).timeout
			disc_right.hide()
			disc_back.show()
 

# TODO: put hitbox manipulations all in same place?
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"road_rash_left":
			disc_left_sc.hitbox_active = true
		"road_rash_left_back":
			left_disc_out = false
		"road_rash_right":
			disc_right_sc.hitbox_active = true
		"road_rash_right_back":
			right_disc_out = false


func _on_disc_attack_cooldown_timeout() -> void:
	disc_attack_available = true
