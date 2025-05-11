extends Node3D

var current_level_path := ""
var current_level_instance : Node3D
var players_alive : int
var enemies_alive : int
var allies_alive : int
@export var max_trails := 3000


func _ready():
	SignalBus.player_spawned.connect(increment_players_alive)
	SignalBus.ai_spawned.connect(increment_ais_alive)
	SignalBus.player_just_fuckkin_died.connect(decrement_players_alive)
	SignalBus.ai_just_fuckkin_died.connect(decrement_ais_alive)

func _process(delta):
	pass


func start_main_menu():
	get_parent().get_node("LoadingScreen").show()
	for child in get_children():
		child.queue_free()
	var main_menu = load("res://main_menu.tscn").instantiate()
	main_menu.level_controller = self
	add_child(main_menu)
	get_parent().get_node("LoadingScreen").hide()


func start_new_level(level_path):
	get_parent().get_node("LoadingScreen").show()
	for child in get_children():
		child.queue_free()
	players_alive = 0
	enemies_alive = 0
	allies_alive = 0
	current_level_path = level_path
	current_level_instance = load(level_path).instantiate()
	current_level_instance.level_controller = self
	current_level_instance.max_trails = max_trails
	await get_tree().create_timer(1).timeout
	add_child(current_level_instance)
	get_parent().get_node("LoadingScreen").hide()


func restart_level():
	start_new_level(current_level_path)


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
