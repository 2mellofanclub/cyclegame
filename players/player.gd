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
var driver_color := "blue"
var cycle_color := "blue"
var lw_color := "blue"
var lw_special := false
var hp := 400.0
var dead := false
var explodable := true
var controllable := true
var lw_active := false
var las_pos := Vector3.ZERO
var las_rot := Vector3.ZERO
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var level_instance: Node3D
# player specific
var targetable = true
var qt_cam_inverter := 1.0
var disc_attack_available := true
var right_disc_out := false
var left_disc_out := false
var road_rash_side := ""

@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var default_cam = $CamTwist/CamPitch/SpringArm3D/Camera3D
@onready var sbm = $sapientblockman/Armature/Skeleton3D/SBM
@onready var disc_back = $sapientblockman/Armature/Skeleton3D/IdiscBack
@onready var disc_left = $sapientblockman/Armature/Skeleton3D/IdiscLeft
@onready var disc_left_sc = $sapientblockman/Armature/Skeleton3D/IdiscLeft/IdentityDisc
@onready var disc_right = $sapientblockman/Armature/Skeleton3D/IdiscRight
@onready var disc_right_sc = $sapientblockman/Armature/Skeleton3D/IdiscRight/IdentityDisc
@onready var LightWall = preload("res://objects/lightwallseg.tscn")
@onready var SpecialLightWall= preload("res://objects/speciallightwallseg.tscn")
@onready var Destruction = load("res://destruction/destruction.tscn")
@onready var destruction_instance = Destruction.instantiate()

 
func _ready():
	las_pos = global_position
	las_rot = global_rotation
	
	disc_left_sc.disc_owner = self
	disc_right_sc.disc_owner = self
	


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
	


func get_last_pos():
	return las_pos
func get_last_rot():
	return las_rot
	
func set_last_pos(pos: Vector3):
	las_pos = pos
func set_last_rot(rot: Vector3):
	las_rot = rot


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
	default_cam.make_current()
	SignalBus.player_just_fuckkin_died.emit()
	explodable = false
	steering = 0
	engine_force = 0
	$IDunno/TrailEater.translate(Vector3(0, 100, 0))
	# i'm something of an animator myself
	if get_linear_velocity().length() < 3:
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
					randi_range(-10, 10),
					randi_range(10, 20),
					randi_range(-10, 10)
			) + last_lin_vel * 0.3)
		await get_tree().create_timer(13).timeout
		destruction_instance.queue_free()
	print("boom")


func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		SignalBus.player_became_untargetable.emit()
		$sapientblockman.hide()
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


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens


func _on_kill_timeout() -> void:
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
