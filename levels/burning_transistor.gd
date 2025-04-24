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

@onready var intro_cam = $CameraTwist/CameraPitch/IntroCam
#@onready var spawn_cam = $CameraTwist/CameraPitch/IntroCam


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _process(delta):
	
	
	
	if intro_cam.current:
		$CameraTwist.rotate_y(delta * PI/10)
	if in_intro and Input.is_anything_pressed():
		in_intro = false
		#spawn_cam.current = true
		await get_tree().create_timer(0.25).timeout
		#region Initial Spawns
		for spawn in $Spawns/Players.get_children():
			Spawner.spawn_player_cycle(spawn, self, "blue", "blue", "blue")
		for spawn in $Spawns/Enemies.get_children():
			if randi() % 2 == 0:
				Spawner.spawn_enemy_cycle(spawn, self, "yellow", "orange", "orange")
			else:
				Spawner.spawn_enemy_cycle(spawn, self, "orange", "yellow", "yellow")
		for spawn in $Spawns/Allies.get_children():
			Spawner.spawn_ally_cycle(spawn, self, "green", "green", "green")
		#endregion
		await get_tree().create_timer(3).timeout
		$SOS.play()
		
