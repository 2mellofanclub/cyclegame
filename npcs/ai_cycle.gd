extends VehicleBody3D

var front_steer := 1.0
var rear_steer := 0.0
var engine_power := 400.0
var max_speed := 80.0
var lw_on_th := 50.0
var lw_off_th := 15.0
var deadly_impact_th := 70.0
var kill_speed := 3.0
var qt_available := true
var driver_color := "pink"
var cycle_color := "pink"
var lw_color := "pink"
var lw_special := false
var hp := 400.0
var dead := false
var explodable := true
var controllable := false
var lw_active := false
var las_pos := Vector3.ZERO
var las_rot := Vector3.ZERO
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var level_instance: Node3D
# ai specific
var ai_type := "ally"
var cam_active := false
var target_cycle := VehicleBody3D
var target_point := Node3D
var move_mode := "patrol"
var hunt_available = true
var backoff_dist = 4.0

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var default_cam = $CamTwist/CamPitch/SpringArm3D/Camera3D
@onready var sbm = $sapientblockman/Armature/Skeleton3D/SBM
@onready var disc_back = $sapientblockman/Armature/Skeleton3D/IdiscBack
@onready var disc_left = $sapientblockman/Armature/Skeleton3D/IdiscLeft
@onready var disc_left_sc = $sapientblockman/Armature/Skeleton3D/IdiscLeft/IdentityDisc
@onready var disc_right = $sapientblockman/Armature/Skeleton3D/IdiscRight
@onready var disc_right_sc = $sapientblockman/Armature/Skeleton3D/IdiscRight/IdentityDisc
@onready var nav_agent = $NavAgent
@onready var LightWall = preload("res://objects/lightwallseg.tscn")
@onready var SpecialLightWall= preload("res://objects/speciallightwallseg.tscn")
@onready var Destruction = load("res://destruction/destruction.tscn")
@onready var destruction_instance = Destruction.instantiate()

 
func _ready():
	las_pos = get_global_position()
	las_rot = get_global_rotation()
	
	disc_left_sc.disc_owner = self
	disc_right_sc.disc_owner = self


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
	if (lin_vel * Vector3(1, 0, 1)).length() > lw_on_th or move_mode == "hunt":
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
	match move_mode:
		"hunt":
			engine_force = 0
			if player_instance == null:
				move_mode = "patrol"
			elif player_l_hunt_target_distance <= backoff_dist or player_r_hunt_target_distance <= backoff_dist:
				move_mode = "patrol"
				hunt_available = false
				$HuntCooldown.start()
			else:
				if player_r_hunt_target_distance < player_l_hunt_target_distance:
					nav_agent.target_position = player_r_hunt_target_pos
				else:
					nav_agent.target_position = player_l_hunt_target_pos
				var direction = nav_agent.get_next_path_position() - global_position
				var velocity = direction.normalized() * max_speed * delta
				if not nav_agent.is_navigation_finished() and nav_agent.distance_to_target() > 27.0:
					if global_position.distance_to(nav_agent.get_next_path_position()) > 2.0:
						look_at(global_position + direction)
				move_and_collide(velocity)
		"patrol":
			engine_force = 400 if (xz_lin_vel.length() < 80) else 0
			if player_targetable:
				if player_l_hunt_target_distance > backoff_dist and player_r_hunt_target_distance > backoff_dist:
					move_mode = "hunt"
			
	
	avoid_lightwall(xz_lin_vel)
	#endregion


func get_last_pos():
	return las_pos
func get_last_rot():
	return las_rot
func set_last_pos(pos: Vector3):
	las_pos = pos
func set_last_rot(rot: Vector3):
	las_rot = rot


func spawn_lw():
	var glo_pos = get_global_position()
	var distance = (las_pos).distance_to(glo_pos)
	var mid_point = Vector3(
		(las_pos.x + glo_pos.x) / 2.0,
		(las_pos.y + glo_pos.y) / 2.0,
		(las_pos.z + glo_pos.z) / 2.0,
	)
	var lw_instance
	if lw_special:
		lw_instance = SpecialLightWall.instantiate()
	else:
		lw_instance = LightWall.instantiate()
	var trails = level_instance.get_node("Trails")
	trails.add_child(lw_instance)
	lw_instance.lw_color = lw_color
	lw_instance.Driver = self
	if trails.get_child_count() >= level_instance.max_trails:
		trails.get_child(0).free()
	lw_instance.set_global_position(mid_point)
	lw_instance.set_global_rotation(las_rot)
	var lw_width = lw_instance.LW_BASE_WIDTH
	lw_instance.scale_object_local(Vector3(1, 1, distance/lw_width))


func explode():
	if not explodable:
		return
	print("boom")
	SignalBus.ai_just_fuckkin_died.emit(ai_type)
	explodable = false
	steering = 0
	engine_force = 0
	$IDunno/TrailEater.translate(Vector3(0, 100, 0))
	# i'm something of an animator myself
	if get_linear_velocity().length() < 30 and not move_mode == "hunt":
		set_linear_velocity(Vector3.ZERO)
		$Explode.play()
		$lightcycle/Frontwheel.hide()
		$FrontRight/OmniLight3D2.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Body.hide()
		$sapientblockman.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Rearwheel.hide()
		$BackRight/OmniLight3D.hide()
	else:
		var last_lin_vel = get_linear_velocity()
		set_linear_velocity(Vector3.ZERO)
		$Explode.play()
		get_parent().add_child(destruction_instance)
		destruction_instance.set_global_position(global_position)
		$sapientblockman.hide()
		for child in $lightcycle.get_children():
			child.hide()
		$FrontRight/OmniLight3D2.hide()
		$BackRight/OmniLight3D.hide()
		destruction_instance.cycle_color = cycle_color
		destruction_instance.prepare()
		for child in destruction_instance.get_children():
			child.apply_impulse(Vector3(
					randi_range(-20, 20),
					randi_range(20, 30),
					randi_range(-20, 20)
			) + last_lin_vel * 0.3)
		await get_tree().create_timer(13).timeout
		destruction_instance.queue_free()


func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		explode()


func take_hit(shot_pos, dmg_value):
	take_dmg(dmg_value)
	$Hit.play()


func apply_materials():
	var lc_materials = MaterialsBus.LC_STYLES
	sbm.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	sbm.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_back.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_back.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_left.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_left.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_right.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_right.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	$lightcycle/Body.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Body.set_surface_override_material(1, lc_materials[cycle_color]["body1"])
	$lightcycle/Body/Windshield_001.set_surface_override_material(0, lc_materials[cycle_color]["body1"])
	$lightcycle/Rearwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Rearwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])
	$lightcycle/Frontwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Frontwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])


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


func _unhandled_input(event):
	if event is InputEventMouseMotion and cam_active:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens

func _on_kill_timeout() -> void:
	take_dmg(10000.0)

func _on_qt_cooldown_timeout() -> void:
	qt_available = true

func _on_despawn_timeout() -> void:
	queue_free()


func _on_hunt_cooldown_timeout() -> void:
	hunt_available = true
