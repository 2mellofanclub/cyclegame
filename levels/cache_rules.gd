extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := false
var players = []
var enemies = []
var allies = []
var recognizers = []

var capsules_available := 0
var capsules_collected := 0
var made_it_to_center = false

@export var pulse_offset := 500.0
@export var pulse_band_offset := 0.6
@export var pulse_speed_mps := 50.0

@onready var intro_cam = $CameraTwist/CameraPitch/IntroCam
@onready var player_tank_spawn_cam = $Spawns/PlayerTanks/PlayerSpawn/SpawnCam
@onready var maze_ab = $MazeAB
@onready var maze_bc = $MazeBC
@onready var maze_cd = $MazeCD
@onready var maze_da = $MazeDA


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.data_capsule_collected.connect(increment_capsules_found)
	SignalBus.data_capsule_collected.connect(spawn_rec_wave)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(0.5).timeout
	maze_ab.activate(6, 12)
	maze_bc.activate(6, 12)
	maze_cd.activate(6, 11)
	maze_da.activate(6, 12)
	await get_tree().create_timer(0.1).timeout
	capsules_available = $DataCapsules.get_child_count()
	for child in $DataCapsules.get_children():
		child.show()
	in_intro = true
	
	


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.pause_toggled.emit()
	
	if intro_cam.current and in_intro:
		$CameraTwist.rotate_y(delta * PI/10)
	if in_intro and Input.is_action_just_pressed("interact"):
		player_tank_spawn_cam.current = true
		in_intro = false
		#region Initial Spawns
		for spawn in $Spawns/PlayerTanks.get_children():
			#Spawner.spawn_player_tank(spawn, self, "blue", "blue")
			Spawner.spawn_player_tank(spawn, self)
		for spawn in $Spawns/EnemyTanks.get_children():
			Spawner.spawn_enemy_tank(spawn, self, "orange", "orange")
			#if randi() % 2 == 0:
				#Spawner.spawn_enemy_cycle(spawn, self, "orange", "orange")
			#else:
				#Spawner.spawn_enemy_cycle(spawn, self, "yellow", "yellow")
		#for spawn in $Spawns/Recognizers.get_children():
			#Spawner.spawn_recognizer(spawn, self,"orange")
		#endregion
		$DataHuntHUD.update_data(capsules_collected, capsules_available)
		$DataHuntHUD.show()
		$DataHuntHUD.clock_active = true





func increment_capsules_found():
	capsules_collected += 1
	$DataHuntHUD.update_data(capsules_collected, capsules_available)


func spawn_rec_wave():
	# this sucks ass since we assume there's only one!
	$Spawns/Recognizers.look_at(players[0].global_position)
	$Spawns/Recognizers.rotation *= Vector3(0, 1, 0)
	for spawn in $Spawns/Recognizers.get_children():
		Spawner.spawn_recognizer(spawn, self, "orange")
	


func win():
	for player in players:
		player.apply_impulse(Vector3(randi_range(-1000, 1000), 20000, randi_range(-1000, 1000)))


func _on_center_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		made_it_to_center = true
		if capsules_collected >= capsules_available:
			$NavigationRegion3D/Pillar.lower()


func _on_win_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		win()
