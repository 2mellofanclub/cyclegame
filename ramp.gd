extends Node3D

const RAMP_PHYSICS = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# temporary workaround to lightcycle tipping over:
func _on_ramparea_body_entered(body):
	if (not RAMP_PHYSICS) and body.name == "Player":
		body.rotate_object_local(Vector3(1, 0, 0), PI/9)
		print("in")
func _on_ramparea_body_exited(body):
	if  (not RAMP_PHYSICS) and body.name == "Player":
		body.rotate_object_local(Vector3(1, 0, 0), -PI/9)
		print("out")
