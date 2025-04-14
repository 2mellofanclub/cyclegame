extends Node3D


var current_level_instance : Node3D
var players_alive: int
var enemies_alive: int
var allies_alive: int
@export var max_trails := 3000
@onready var Player = preload("res://players/player.tscn")
@onready var PlayerTank = preload("res://players/player_tank.tscn")
@onready var AICycle = preload("res://npcs/ai_cycle.tscn")
@onready var AITank = preload("res://npcs/ai_tank.tscn")
@onready var Recognizer = preload("res://npcs/recognizer.tscn")


func _ready():
	SignalBus.player_spawned.connect(increment_players_alive)
	SignalBus.ai_spawned.connect(increment_ais_alive)
	SignalBus.player_just_fuckkin_died.connect(decrement_players_alive)
	SignalBus.ai_just_fuckkin_died.connect(decrement_ais_alive)
	SignalBus.spawns_requested.connect(spawn_everybody)

func _process(delta):
	pass


func start_new_level(level_path):
	for child in get_children():
		child.queue_free()
	players_alive = 0
	enemies_alive = 0
	allies_alive = 0
	current_level_instance = load(level_path).instantiate()
	current_level_instance.level_controller = self
	current_level_instance.max_trails = max_trails
	add_child(current_level_instance)
	


func spawn_everybody():
	spawn_player_cycles(current_level_instance)
	spawn_player_tanks(current_level_instance)
	spawn_ally_cycles(current_level_instance)
	spawn_ally_tanks(current_level_instance)
	spawn_enemy_cycles(current_level_instance)
	spawn_enemy_tanks(current_level_instance)
	spawn_recognizers(current_level_instance)

func spawn_player_cycles(level_instance):
	if level_instance.get_node("Spawns/Players").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/Players").get_children():
		var player_instance = Player.instantiate()
		level_instance.add_child(player_instance)
		player_instance.cycle_color = "orange"
		player_instance.lw_color = "orange"
		player_instance.level_instance = level_instance
		player_instance.apply_materials()
		player_instance.set_global_position(point.get_global_position())
		player_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.player_spawned.emit()

func spawn_enemy_cycles(level_instance):
	if level_instance.get_node("Spawns/Enemies").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/Enemies").get_children():
		var enemy_instance = AICycle.instantiate()
		level_instance.get_node("NPCs").add_child(enemy_instance)
		if point.get_index() == 1:
			enemy_instance.cycle_color = "yellow"
			enemy_instance.lw_color = "yellow"
			enemy_instance.apply_materials()
		else:
			enemy_instance.cycle_color = "orange"
			enemy_instance.lw_color = "orange"
			enemy_instance.apply_materials()
		enemy_instance.level_instance = level_instance
		enemy_instance.set_global_position(point.get_global_position())
		enemy_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.ai_spawned.emit("enemy")

func spawn_ally_cycles(level_instance):
	if level_instance.get_node("Spawns/Allies").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/Allies").get_children():
		var ally_instance = AICycle.instantiate()
		level_instance.get_node("NPCs").add_child(ally_instance)
		ally_instance.cycle_color = "green"
		ally_instance.lw_color = "green"
		ally_instance.level_instance = level_instance
		ally_instance.apply_materials()
		ally_instance.set_global_position(point.get_global_position())
		ally_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.ai_spawned.emit("ally")

func spawn_player_tanks(level_instance):
	if level_instance.get_node("Spawns/PlayerTanks").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/PlayerTanks").get_children():
		var player_instance = PlayerTank.instantiate()
		level_instance.add_child(player_instance)
		level_instance.players.append(player_instance)
		player_instance.tank_color = "green"
		player_instance.shot_color = "green"
		player_instance.level_instance = level_instance
		player_instance.apply_materials()
		player_instance.set_global_position(point.get_global_position())
		player_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.player_spawned.emit()

func spawn_enemy_tanks(level_instance):
	if level_instance.get_node("Spawns/EnemyTanks").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/EnemyTanks").get_children():
		var enemy_instance = AITank.instantiate()
		#level_instance.get_node("Enemies").add_child(enemy_instance)
		level_instance.add_child(enemy_instance)
		level_instance.enemies.append(enemy_instance)
		enemy_instance.tank_color = "orange"
		enemy_instance.shot_color = "orange"
		enemy_instance.enemy = true
		enemy_instance.level_instance = level_instance
		enemy_instance.apply_materials()
		enemy_instance.set_global_position(point.get_global_position())
		enemy_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.ai_spawned.emit("enemy")

func spawn_ally_tanks(level_instance):
	if level_instance.get_node("Spawns/AllyTanks").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/AllyTanks").get_children():
		var ally_instance = AITank.instantiate()
		level_instance.add_child(ally_instance)
		level_instance.allies.append(ally_instance)
		ally_instance.tank_color = "blue"
		ally_instance.shot_color = "blue"
		ally_instance.level_instance = level_instance
		ally_instance.apply_materials()
		ally_instance.set_global_position(point.get_global_position())
		ally_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.ai_spawned.emit("ally")

func spawn_recognizers(level_instance):
	if level_instance.get_node("Spawns/Recognizers").get_child_count() == 0:
		return
	for point in level_instance.get_node("Spawns/Recognizers").get_children():
		var enemy_instance = Recognizer.instantiate()
		level_instance.add_child(enemy_instance)
		level_instance.recognizers.append(enemy_instance)
		enemy_instance.rec_color = "orange"
		enemy_instance.enemy = true
		enemy_instance.level_instance = level_instance
		enemy_instance.apply_materials()
		enemy_instance.set_global_position(point.get_global_position())
		enemy_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.ai_spawned.emit("enemy")


func increment_players_alive():
	players_alive += 1
func decrement_players_alive():
	players_alive -= 1
func increment_ais_alive(aitype):
	if aitype == "enemy":
		enemies_alive += 1
	else:
		allies_alive += 1
func decrement_ais_alive(aitype):
	if aitype == "enemy":
		enemies_alive -= 1
	else:
		allies_alive -= 1
