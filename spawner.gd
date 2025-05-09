extends Node

@onready var Player = preload("res://players/player.tscn")
@onready var PlayerTank = preload("res://players/player_tank.tscn")
@onready var AICycle = preload("res://npcs/ai_cycle.tscn")
@onready var AITank = preload("res://npcs/ai_tank.tscn")
@onready var Recognizer = preload("res://npcs/recognizer.tscn")

@onready var RecDummy = preload("res://npc_dummies/recognizer_dummy.tscn")


func spawn_player_cycle(spawn: Node3D, level_instance: Node, driver_color: String, cycle_color: String, lw_color: String):
	var player_instance = Player.instantiate()
	level_instance.add_child(player_instance)
	level_instance.players.append(player_instance)
	player_instance.driver_color = driver_color
	player_instance.cycle_color = cycle_color
	player_instance.lw_color = lw_color
	player_instance.level_instance = level_instance
	player_instance.apply_materials()
	player_instance.set_global_position(spawn.get_global_position())
	player_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.player_spawned.emit()


func spawn_enemy_cycle(spawn: Node3D, level_instance: Node, driver_color: String, cycle_color: String, lw_color: String):
	var enemy_instance = AICycle.instantiate()
	level_instance.add_child(enemy_instance)
	level_instance.enemies.append(enemy_instance)
	enemy_instance.driver_color = driver_color
	enemy_instance.cycle_color = cycle_color
	enemy_instance.lw_color = lw_color
	enemy_instance.level_instance = level_instance
	enemy_instance.ai_type = "enemy"
	enemy_instance.apply_materials()
	enemy_instance.set_global_position(spawn.get_global_position())
	enemy_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("enemy")


func spawn_ally_cycle(spawn: Node3D, level_instance: Node, driver_color: String, cycle_color: String, lw_color: String):
	var ally_instance = AICycle.instantiate()
	level_instance.add_child(ally_instance)
	level_instance.allies.append(ally_instance)
	ally_instance.driver_color = driver_color
	ally_instance.cycle_color = cycle_color
	ally_instance.lw_color = lw_color
	ally_instance.level_instance = level_instance
	ally_instance.ai_type = "ally"
	ally_instance.apply_materials()
	ally_instance.set_global_position(spawn.get_global_position())
	ally_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("ally")


func spawn_player_tank(spawn: Node3D, level_instance: Node, tank_color: String, shot_color: String):
	var player_instance = PlayerTank.instantiate()
	level_instance.add_child(player_instance)
	level_instance.players.append(player_instance)
	player_instance.tank_color = tank_color
	player_instance.shot_color = shot_color
	player_instance.level_instance = level_instance
	player_instance.apply_materials()
	player_instance.set_global_position(spawn.get_global_position())
	player_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.player_spawned.emit()


func spawn_enemy_tank(spawn: Node3D, level_instance: Node, tank_color: String, shot_color: String):
	var enemy_instance = AITank.instantiate()
	level_instance.add_child(enemy_instance)
	level_instance.enemies.append(enemy_instance)
	enemy_instance.tank_color = tank_color
	enemy_instance.shot_color = shot_color
	enemy_instance.enemy = true
	enemy_instance.level_instance = level_instance
	enemy_instance.apply_materials()
	enemy_instance.set_global_position(spawn.get_global_position())
	enemy_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("enemy")


func spawn_ally_tank(spawn: Node3D, level_instance: Node, tank_color: String, shot_color: String):
	var ally_instance = AITank.instantiate()
	level_instance.add_child(ally_instance)
	level_instance.allies.append(ally_instance)
	ally_instance.tank_color = tank_color
	ally_instance.shot_color = shot_color
	ally_instance.level_instance = level_instance
	ally_instance.apply_materials()
	ally_instance.set_global_position(spawn.get_global_position())
	ally_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("ally")


func spawn_recognizer(spawn: Node3D, level_instance: Node, rec_color: String):
	var enemy_instance = Recognizer.instantiate()
	level_instance.add_child(enemy_instance)
	level_instance.recognizers.append(enemy_instance)
	enemy_instance.rec_color = rec_color
	enemy_instance.enemy = true
	enemy_instance.level_instance = level_instance
	enemy_instance.apply_materials()
	enemy_instance.set_global_position(spawn.get_global_position())
	enemy_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("enemy")
	
func spawn_rec_dummy(spawn: Node3D, level_instance: Node, rec_color: String):
	var enemy_instance = RecDummy.instantiate()
	level_instance.add_child(enemy_instance)
	level_instance.recognizers.append(enemy_instance)
	enemy_instance.rec_color = rec_color
	enemy_instance.enemy = true
	enemy_instance.level_instance = level_instance
	enemy_instance.apply_materials()
	enemy_instance.set_global_position(spawn.get_global_position())
	enemy_instance.set_global_rotation(spawn.get_global_rotation())
	SignalBus.ai_spawned.emit("enemy")
