extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := true
var players = []
var enemies = []
var allies = []
var recognizers = []
@export var pulse_offset := 500.0
@export var pulse_band_offset := 0.6
@export var pulse_speed_mps := 50.0

@onready var IntroCam = $CameraTwist/CameraPitch/IntroCam
@onready var PlayerTankSpawnCam = $Spawns/PlayerTanks/PlayerSpawn/SpawnCam


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.pause_toggled.emit()
	
	
	pulse_offset -= delta * pulse_speed_mps
	if pulse_offset < 0.0:
		pulse_offset = 500.0
	$BaseNav/LightfloorCross.get_surface_override_material(1).set_shader_parameter(
			"pulse_offset", pulse_offset
	)
	$BaseNav/LightfloorCross.get_surface_override_material(1).set_shader_parameter(
			"pulse_band_offset", pulse_band_offset
	)
	
	if IntroCam.current:
		$CameraTwist.rotate_y(delta * PI/10)
	if in_intro and Input.is_anything_pressed():
		in_intro = false
		PlayerTankSpawnCam.current = true
		await get_tree().create_timer(0.25).timeout
		#region Initial Spawns
		for spawn in $Spawns/PlayerTanks.get_children():
			Spawner.spawn_player_tank(spawn, self, "blue", "blue")
		for spawn in $Spawns/EnemyTanks.get_children():
			Spawner.spawn_enemy_tank(spawn, self, "orange", "orange")
			#if randi() % 2 == 0:
				#Spawner.spawn_enemy_cycle(spawn, self, "orange", "orange")
			#else:
				#Spawner.spawn_enemy_cycle(spawn, self, "yellow", "yellow")
		for spawn in $Spawns/Recognizers.get_children():
			Spawner.spawn_recognizer(spawn, self,"orange")
		#endregion
		await get_tree().create_timer(3).timeout
		print(enemies)
		#$SOS.play()
		
