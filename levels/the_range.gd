extends Node3D


var level_controller: Node3D
var max_trails: int


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SOS.play()


func _process(delta):
	pass


#botbot
