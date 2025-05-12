extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := false
var players = []
var enemies = []
var allies = []
var recognizers = []
@export var pulse_offset := 500.0
@export var pulse_band_offset := 0.6
@export var pulse_speed_mps := 50.0

@onready var intro_cam = $CameraTwist/CameraPitch/IntroCam
@onready var player_tank_spawn_cam = $Spawns/PlayerTanks/PlayerSpawn/SpawnCam
@onready var maze_ab = $NavigationRegion3D/A/MazeAB
@onready var maze_bc = $NavigationRegion3D/B/MazeBC
@onready var maze_cd = $NavigationRegion3D/C/MazeCD
@onready var maze_da = $NavigationRegion3D/D/MazeDA


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(0.5).timeout
	maze_ab.activate(12, 25)
	maze_bc.activate(12, 25)
	maze_cd.activate(12, 24)
	maze_da.activate(12, 25)
	await get_tree().create_timer(1).timeout
	in_intro = true
	
	


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.pause_toggled.emit()
	
	$SpotLightPivot.rotate_y(delta * PI/4)
	
	
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
		$DataHuntHUD.show()
		$DataHuntHUD.clock_active = true
		
		
