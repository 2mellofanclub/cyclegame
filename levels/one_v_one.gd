extends Node3D


var level_controller: Node3D
var max_trails: int
@export var ft_active := false


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SOS.play()


func _process(delta):
	pass


#botbot
func _on_bot_turn_left_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn("left")
func _on_bot_turn_right_body_entered(body: Node3D) -> void:
	if "quickturn" in body:
		body.quickturn("right")


func _on_kill_box_body_entered(body: Node3D) -> void:
	if "explode" in body:
		body.explode()
func _on_despawn_box_body_entered(body: Node3D) -> void:
	body.queue_free()


func _on_funky_town_body_entered(body: Node3D) -> void:
	if not ft_active:
		return
	body.gravity_scale = -1.0
	await get_tree().create_timer(1).timeout
	body.rotate_object_local(Vector3(0, 0, 1), PI)
	#body.get_node("CamTwist/CamPitch/SpringArm3D").rotate_object_local(Vector3(0, 0, 1), PI)
func _on_funky_town_body_exited(body: Node3D) -> void:
	if not ft_active:
		return
	body.gravity_scale = 1.0
	await get_tree().create_timer(1).timeout
	body.rotate_object_local(Vector3(0, 0, 1), PI)
	#body.get_node("CamTwist/CamPitch/SpringArm3D").rotate_object_local(Vector3(0, 0, 1), PI)
	
