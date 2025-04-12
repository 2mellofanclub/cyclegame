extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := true

@onready var IntroCam = $CameraTwist/CameraPitch/IntroCam
@onready var PlayerTankSpawnCam = $Spawns/PlayerTanks/PlayerSpawn/SpawnCam


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


func _process(delta):
	if IntroCam.current:
		$CameraTwist.rotate_y(delta * PI/10)
	if in_intro and Input.is_anything_pressed():
		in_intro = false
		PlayerTankSpawnCam.current = true
		await get_tree().create_timer(0.25).timeout
		SignalBus.spawns_requested.emit()
		await get_tree().create_timer(3).timeout
		$SOS.play()
		

		


#botbot
