extends Node3D


var current_level_instance : Node3D
var drivers_alive: int
@export var max_trails := 3000
@onready var Player = preload("res://objects/player.tscn")
@onready var AICycle = preload("res://npcs/ai_cycle.tscn")


func _ready():
	SignalBus.driver_spawned.connect(increment_living)
	SignalBus.driver_just_fuckkin_died.connect(decrement_living)

func _process(delta):
	pass


func start_new_level(level_path):
	for child in get_children():
		child.queue_free()
	drivers_alive = 0
	current_level_instance = load(level_path).instantiate()
	current_level_instance.level_controller = self
	current_level_instance.max_trails = max_trails
	add_child(current_level_instance)
	spawn_players(current_level_instance)
	spawn_allies(current_level_instance)
	spawn_enemies(current_level_instance)


func spawn_players(level_instance):
	for point in level_instance.get_node("Spawns/Players").get_children():
		var player_instance = Player.instantiate()
		level_instance.add_child(player_instance)
		player_instance.cycle_color = "blue"
		player_instance.lw_color = "blue"
		player_instance.level_instance = level_instance
		player_instance.apply_materials()
		player_instance.set_global_position(point.get_global_position())
		player_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.driver_spawned.emit()


# by no means final
func spawn_enemies(level_instance):
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
		SignalBus.driver_spawned.emit()


func spawn_allies(level_instance):
	for point in level_instance.get_node("Spawns/Allies").get_children():
		var ally_instance = AICycle.instantiate()
		level_instance.get_node("NPCs").add_child(ally_instance)
		ally_instance.cycle_color = "green"
		ally_instance.lw_color = "green"
		ally_instance.level_instance = level_instance
		ally_instance.apply_materials()
		ally_instance.set_global_position(point.get_global_position())
		ally_instance.set_global_rotation(point.get_global_rotation())
		SignalBus.driver_spawned.emit()
		

func increment_living():
	drivers_alive += 1
func decrement_living():
	drivers_alive -= 1
