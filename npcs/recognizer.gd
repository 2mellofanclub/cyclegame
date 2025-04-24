extends RigidBody3D

var level_instance : Node3D
var rec_color := "blue"
var materials_applied := false
var max_speed := 30.0
var max_hp := 2000.0
var hp := 2000.0
var dead := false
var explodable := true
# ai specific
var enemy := false
var targeting := false
var move_mode := "hunt"
var max_targeting_dist := 150.0
# for both patrol and hunt
var cruising_alt := 40.0
var move_in_xz_distance := 50
var move_in_alt := 15.0
var crush_xz_distance := 20.0
var in_animation := false
var crush_ready := false
var crush_dot_dmg := 10000.0
var target_in_box := false
var dot_target

@onready var nav_agent = $NavAgent
#@onready var Cube = load("res://destruction/cube.tscn")

func _ready():
	pass
	
func _process(delta: float) -> void:
	if materials_applied:
		var points_to_pass = []
		for d_dot in $DamageDots.get_children():
			points_to_pass.append(Vector4(
					d_dot.get_global_position().x,
					d_dot.get_global_position().y,
					d_dot.get_global_position().z,
					d_dot.scale.x
			))
		$Recbody.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
		$RBLL/Leftleg.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
		$RBRL/Rightleg.get_surface_override_material(0).set_shader_parameter("dmg_points", points_to_pass)
	
	if dead:
		return
	
	#region PlayerLoc
	var player_instance = level_instance.players[0]
	var player_location
	var player_targetable
	var player_distance
	var player_xz_distance
	if player_instance:
		player_location = player_instance.global_position
		player_targetable = player_instance.targetable
		player_distance = player_location.distance_to(global_position)
		player_xz_distance = (player_location * Vector3(1,0,1)).distance_to(global_position * Vector3(1,0,1))
	#endregion
	
	#region Steering
	#print(move_mode)
	if move_mode != "still":
		if player_location == null or not player_targetable:
			move_mode = "still"
	match move_mode:
		"hunt":
			var cruise_target = player_location * Vector3(1, 0, 1) + Vector3(0.0, cruising_alt, 0.0)
			var direction = global_position.direction_to(cruise_target)
			var velocity = direction.normalized() * max_speed/2.0 * delta
			Utilities.look_at_xz(self, (cruise_target + direction))
			move_and_collide(velocity)
			if player_xz_distance < move_in_xz_distance:
				move_mode = "move_in"
		"move_in":
			nav_agent.path_height_offset = -move_in_alt
			nav_agent.target_position = player_location
			var next_position = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_position)
			var velocity = direction.normalized() * max_speed/2.0 * delta
			if not nav_agent.is_navigation_finished():
				Utilities.look_at_xz(self, (global_position + direction))
				move_and_collide(velocity)
			if player_xz_distance < crush_xz_distance:
				# not strictly necessary here
				in_animation = true
				$AnimationPlayer.play("crush")
				move_mode = "crush"
		"crush":
			var crush_location = player_location * Vector3(1, 0, 1) + Vector3(0.0, 2.3, 0.0)
			var direction = global_position.direction_to(crush_location)
			var velocity = direction.normalized() * max_speed/4.0 * delta
			Utilities.look_at_xz(self, (global_position + direction))
			move_and_collide(velocity)
			if crush_ready and target_in_box:
				if dot_target.dead == true:
					target_in_box = false
					dot_target = null
					move_mode = "still"
				else:
					dot_target.take_dmg(crush_dot_dmg * delta)
					$Crush.play()
		"patrol":
			move_mode = "hunt"
		"hover":
			var cruise_target = global_position * Vector3(1, 0, 1) + Vector3(0.0, cruising_alt, 0.0)
			var direction = global_position.direction_to(cruise_target)
			var velocity = direction.normalized() * max_speed/2.0 * delta
			Utilities.look_at_xz(self, (cruise_target + direction))
			move_and_collide(velocity)
			if player_targetable:
				move_mode = "hunt"
		"still":
			# bro i need to fix this state machine bullshit
			if player_targetable:
				move_mode = "hunt"
			else:
				move_mode = "hover"
	#endregion
	


func patrol_to_hunt():
	pass


func apply_materials():
	var rec_materials = MaterialsBus.REC_STYLES
	# duplication necessary for passing instance specific vec4 of ddots
	$Recbody.set_surface_override_material(0, rec_materials[rec_color]["body0"].duplicate())
	$Recbody.set_surface_override_material(1, rec_materials[rec_color]["lines"].duplicate())
	$Recbody/BLattice.set_surface_override_material(0, rec_materials[rec_color]["lattice"])
	$RBLL/Leftleg.set_surface_override_material(0, rec_materials[rec_color]["leftleg"].duplicate())
	$RBLL/Leftleg.set_surface_override_material(1, rec_materials[rec_color]["lines"])
	$RBLL/Leftleg/LLLattice.set_surface_override_material(0, rec_materials[rec_color]["lattice"])
	$RBLL.materials_applied = true
	$RBRL/Rightleg.set_surface_override_material(0, rec_materials[rec_color]["rightleg"].duplicate())
	$RBRL/Rightleg.set_surface_override_material(1, rec_materials[rec_color]["lines"])
	$RBRL/Rightleg/RLLattice.set_surface_override_material(0, rec_materials[rec_color]["lattice"])
	$RBRL.materials_applied = true
	materials_applied = true


func receive_health(source):
	if source == "god":
		hp = 5000.0
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
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		SignalBus.ai_just_fuckkin_died.emit("enemy")
		# so everything has time to stop before explosion frees collision
		await get_tree().create_timer(0.15).timeout
		explode()


func explode():
	if not explodable:
		return
	explodable = false
	$Explode.play()
	dead = true
	$RBLL.freeze = false
	$RBRL.freeze = false
	$RBLL.top_level = true
	$RBRL.top_level = true
	self.gravity_scale = 0.5
	$RBLL.gravity_scale = 0.5
	$RBRL.gravity_scale = 0.5
	apply_impulse(
			Vector3(
				randi_range(-500, 500),
				randi_range(-500, 500),
				randi_range(-500, 500),
			)
	)
	$RBLL.apply_impulse(
			Vector3(
				randi_range(-500, 500),
				randi_range(-500, 500),
				randi_range(-500, 500),
			)
	)
	$RBRL.apply_impulse(
			Vector3(
				randi_range(-500, 500),
				randi_range(-500, 500),
				randi_range(-500, 500),
			)
	)
	# add cube squibs to joints


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	in_animation = false
	crush_ready = true


func _on_crush_box_body_entered(body: Node3D) -> void:
	if body in level_instance.players:
		if body.dead:
			return
		print("DIE!")
		dot_target = body
		target_in_box = true


func _on_crush_box_body_exited(body: Node3D) -> void:
	if body == dot_target:
		target_in_box = false
		dot_target = null
