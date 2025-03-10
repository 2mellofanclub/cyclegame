extends Node3D


const MAX_TRAILS = 1000
@onready var LightWall = preload("res://objects/lightwallseg.tscn")
@onready var Player = preload("res://objects/player.tscn")
@onready var AICycle = preload("res://npcs/ai_cycle.tscn")

func spawn_players():
	for point in $Spawns/Players.get_children():
		var player_instance = Player.instantiate()
		add_child(player_instance)
		player_instance.cycle_color = "blue"
		player_instance.lw_color = "blue"
		player_instance.apply_materials()
		player_instance.set_global_position(point.get_global_position())
		player_instance.set_global_rotation(point.get_global_rotation())


# by no means final
func spawn_enemies():
	for point in $Spawns/Enemies.get_children():
		var enemy_instance = AICycle.instantiate()
		$NPCs.add_child(enemy_instance)
		if point.get_index() == 1:
			enemy_instance.cycle_color = "yellow"
			enemy_instance.lw_color = "yellow"
			enemy_instance.apply_materials()
		else:
			enemy_instance.cycle_color = "orange"
			enemy_instance.lw_color = "orange"
			enemy_instance.apply_materials()
		enemy_instance.set_global_position(point.get_global_position())
		enemy_instance.set_global_rotation(point.get_global_rotation())


func spawn_allies():
	for point in $Spawns/Allies.get_children():
		var ally_instance = AICycle.instantiate()
		$NPCs.add_child(ally_instance)
		ally_instance.cycle_color = "green"
		ally_instance.lw_color = "green"
		ally_instance.apply_materials()
		ally_instance.set_global_position(point.get_global_position())
		ally_instance.set_global_rotation(point.get_global_rotation())


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.spawn_lw.connect(spawn_lw)
	spawn_players()
	spawn_enemies()
	spawn_allies()
	$SOS.play()


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func spawn_lw(Driver):
	var las_pos = Driver.get_last_pos()
	var glo_pos = Driver.get_global_position()
	# revealed to this function in a dream 
	# since lightwall hasn't been instantiated
	var lw_width = 0.6
	var distance = (las_pos).distance_to(glo_pos)
	var mid_point = Vector3(
		(las_pos.x + glo_pos.x) / 2.0,
		(las_pos.y + glo_pos.y) / 2.0,
		(las_pos.z + glo_pos.z) / 2.0,
	)
	var lw_instance = LightWall.instantiate()
	$Trails.add_child(lw_instance)
	lw_instance.lw_color = Driver.lw_color
	lw_instance.Driver = Driver
	if $Trails.get_child_count() >= MAX_TRAILS:
		$Trails.get_child(0).free()
	lw_instance.set_global_position(mid_point)
	lw_instance.set_global_rotation(Driver.get_last_rot())
	lw_instance.scale_object_local(Vector3(1, 1, distance/lw_width))
	Driver.set_last_pos(glo_pos)
	Driver.set_last_rot(Driver.get_global_rotation())


#botbot
func _on_bot_turn_left_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn("left")
func _on_bot_turn_right_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn("right")


func _on_kill_box_body_entered(body: Node3D) -> void:
	if "explode" in body:
		if body.is_explodable():
			body.explode()
func _on_despawn_box_body_entered(body: Node3D) -> void:
	body.queue_free()
