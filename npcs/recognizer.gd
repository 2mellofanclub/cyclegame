extends Node3D

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
var player_targetable := false
var targeting := false
var move_mode := "hunt"
var max_targeting_dist := 150.0
var cruising_alt := 50.0

@onready var nav_agent = $NavAgent
#@onready var Cube = load("res://destruction/cube.tscn")

func _ready():
	SignalBus.player_became_targetable.connect(allow_target_player)
	SignalBus.player_became_untargetable.connect(disallow_target_player)
	
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
	
	var player_location
	var player_distance
	var player_instance = level_instance.get_node_or_null("PlayerTank")
	if player_instance:
		player_location = player_instance.global_position
		player_distance = player_location.distance_to(global_position)
		
	#region Steering
	
	#endregion
	


func allow_target_player():
	player_targetable = true
func disallow_target_player():
	player_targetable = false


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
	$RBLL.apply_impulse(
			Vector3(
				randi_range(-10, 10),
				randi_range(-10, 10),
				randi_range(-10, 10)
			)
	)
	$RBRL.apply_impulse(
			Vector3(
				randi_range(-10, 10),
				randi_range(-10, 10),
				randi_range(-10, 10)
			)
	)
	# add cube squibs to joints
