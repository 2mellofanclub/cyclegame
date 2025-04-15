extends Node3D

@export var ramp_physics = false

# AAAAAAAAAaaaaaaaaAA
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
 

# Called every frame. 'delta' is the elapsed time since the previous frame.azzaaaassasa
func _process(delta):
	pass

# temporary workaround to lightcycle tipping over:
func _on_ramparea_body_entered(body):
	if (not ramp_physics) and "explodable" in body:
		body.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(14.4))
		body.get_node("CamTwist").rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-14.4))
		print("in")
func _on_ramparea_body_exited(body):
	if  (not ramp_physics) and "explodable" in body:
		body.rotate_object_local(Vector3(1, 0, 0), -deg_to_rad(14.4))
		body.get_node("CamTwist").rotate_object_local(Vector3(1, 0, 0), deg_to_rad(14.4))
		print("out")
