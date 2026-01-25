extends CycleBase

# ai specific
enum MOVE_MODE {PATROL, HUNT, STANDBY, AVOID}

var ai_type := "ally"
var cam_active := false
var current_move_mode := MOVE_MODE.PATROL
var patrol_route := {}
var next_patrol_pos : Vector3
var target_cycle : VehicleBody3D
var target_point : Node3D
var hunt_available = true
var backoff_dist = 4.0


@onready var nav_agent = $NavAgent

 
#func _ready():


func _physics_process(delta):
	
	#region Cam
	if default_cam.current:
		cam_twist.rotate_y(twist_input)
		cam_pitch.rotate_x(pitch_input)
		cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, -1, 0.5)
		twist_input = 0
		pitch_input = 0
	#endregion
		
	# stuff below is only for the living 
	if dead:
		return
		
	#botbot
	var lin_vel = get_linear_velocity()
	var xz_lin_vel = lin_vel * Vector3(1, 0, 1)
		
	if xz_lin_vel.length() > deadly_impact_th:
		if $ImpactRay.is_colliding():
			take_dmg(10000.0)
	#if xz_lin_vel.length() < kill_speed:
		#if $KillTimer.is_stopped():
			#$KillTimer.start()
	#else:
		#if not $KillTimer.is_stopped():
			#$KillTimer.stop()
			
	#region LW
	if (lin_vel * Vector3(1, 0, 1)).length() > lw_on_th or current_move_mode == MOVE_MODE.HUNT:
		lw_active = true
	elif (lin_vel * Vector3(1, 0, 1)).length() < lw_off_th:
		lw_active = false
	if las_pos.distance_to(global_position) >= 0.6:
		if lw_active:
			spawn_lw()
		las_pos = get_global_position()
		las_rot = get_global_rotation()
	#endregion
	
	#region Steering
	var player_instance = level_instance.players[0] if len(level_instance.players) > 0 else null
	var player_location
	var player_targetable
	var player_r_hunt_target_pos
	var player_l_hunt_target_pos
	var player_r_hunt_target_distance
	var player_l_hunt_target_distance
	if player_instance:
		player_location = player_instance.global_position
		player_targetable = player_instance.targetable
		player_r_hunt_target_pos = player_instance.get_node("HuntTargetR").global_position
		player_l_hunt_target_pos = player_instance.get_node("HuntTargetL").global_position
		player_r_hunt_target_distance = player_r_hunt_target_pos.distance_to(global_position)
		player_l_hunt_target_distance = player_l_hunt_target_pos.distance_to(global_position)
	#engine_force = 400 if (xz_lin_vel.length() < 80) else 0
	match current_move_mode:
		MOVE_MODE.HUNT:
			engine_force = 0
			if player_instance == null:
				current_move_mode = MOVE_MODE.PATROL
			elif player_l_hunt_target_distance <= backoff_dist or player_r_hunt_target_distance <= backoff_dist:
				current_move_mode = MOVE_MODE.PATROL
				hunt_available = false
				$HuntCooldown.start()
			else:
				if player_r_hunt_target_distance < player_l_hunt_target_distance:
					nav_agent.target_position = player_r_hunt_target_pos
				else:
					nav_agent.target_position = player_l_hunt_target_pos
		MOVE_MODE.PATROL:
			nav_agent.target_position = next_patrol_pos
			
			#if player_targetable:
				#if player_l_hunt_target_distance > backoff_dist and player_r_hunt_target_distance > backoff_dist:
					#current_move_mode = MOVE_MODE.HUNT
	var direction = nav_agent.get_next_path_position() - global_position
	var velocity = direction.normalized() * max_speed * delta
	if not nav_agent.is_navigation_finished() and nav_agent.distance_to_target() > 27.0:
		if global_position.distance_to(nav_agent.get_next_path_position()) > 2.0:
			look_at(global_position + direction)
	move_and_collide(velocity)
	
	avoid_lightwall(xz_lin_vel)
	#endregion


# overwrite
func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		SignalBus.ai_just_fuckkin_died.emit(ai_type)
		explode()


func reset_qt_cooldown():
	qt_available = false
	$QTCooldown.start()


#botbot
func quickturn(dir):
	if not qt_available:
		return
	reset_qt_cooldown()
	var directions = {
		"left": 1,
		"right": -1,
	}
	var lin_vel = get_linear_velocity()
	set_linear_velocity(Vector3.ZERO)
	rotate_y(PI/2 * directions[dir])
	las_rot = get_global_rotation()
	cam_twist.rotate_y(PI/2 * -directions[dir])
	set_linear_velocity(-directions[dir] * Vector3(-lin_vel.z, 0, lin_vel.x))


#botbot
# change this to better complement nav
func avoid_lightwall(xz_lin_vel):
	if not qt_available:
		return
	if $FRay.is_colliding():
		#print("we do it")
		if $FLRay.is_colliding():
			quickturn("right")
		elif $FRRay.is_colliding():
			quickturn("left")
		else:
			if randi_range(0, 1) == 0:
				quickturn("left")
			else:
				quickturn("right")
		reset_qt_cooldown()
	elif $FLRay.is_colliding():
		reset_qt_cooldown()
		var old_vel = xz_lin_vel
		var angle_to_normal = xz_lin_vel.angle_to($FLRay.get_collision_normal())
		var rotate_angle = -1 * (angle_to_normal - PI/2)
		#print(rotate_angle)
		set_linear_velocity(Vector3.ZERO)
		rotate_y(rotate_angle)
		set_linear_velocity(old_vel.rotated(Vector3(0, 1, 0), rotate_angle))
	elif $FRRay.is_colliding():
		reset_qt_cooldown()
		var old_vel = xz_lin_vel
		var angle_to_normal = xz_lin_vel.angle_to($FRRay.get_collision_normal())
		var rotate_angle = angle_to_normal - PI/2
		#print(rotate_angle)
		set_linear_velocity(Vector3.ZERO)
		rotate_y(rotate_angle)
		set_linear_velocity(xz_lin_vel.rotated(Vector3(0, 1, 0), rotate_angle))


func _on_qt_cooldown_timeout() -> void:
	qt_available = true

func _on_hunt_cooldown_timeout() -> void:
	hunt_available = true
