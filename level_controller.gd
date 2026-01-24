extends Node3D

var pause_menu : Control
var current_level_path := ""
var current_level_instance : Node3D
var game_pausable := false
var players_alive : int
var enemies_alive : int
var allies_alive : int
@export var max_trails := 3000


func _ready():
	SignalBus.player_spawned.connect(increment_players_alive)
	SignalBus.ai_spawned.connect(increment_ais_alive)
	SignalBus.player_just_fuckkin_died.connect(decrement_players_alive)
	SignalBus.ai_just_fuckkin_died.connect(decrement_ais_alive)
	SignalBus.game_paused.connect(pause)
	SignalBus.game_unpaused.connect(unpause)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and game_pausable:
		SignalBus.game_paused.emit()
		print("ui_cancel")


func pause():
	if not game_pausable:
		return
	get_tree().paused = true
	pause_menu.change_menu_state(0)
	pause_menu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_pausable = false
	
func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.hide()
	get_tree().paused = false
	await get_tree().create_timer(0.2).timeout
	game_pausable = true
	print("game now pausable")


func start_main_menu():
	game_pausable = false
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
	if not level_path == "res://levels/garage.tscn":
		game_pausable = true


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
