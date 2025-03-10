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
	if (not RAMP_PHYSICS) and "explodable" in body:
		body.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(14.4))
		body.get_node("CamTwist").rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-14.4))
		print("in")
func _on_ramparea_body_exited(body):
	if  (not RAMP_PHYSICS) and "explodable" in body:
		body.rotate_object_local(Vector3(1, 0, 0), -deg_to_rad(14.4))
		body.get_node("CamTwist").rotate_object_local(Vector3(1, 0, 0), deg_to_rad(14.4))
		print("out")
