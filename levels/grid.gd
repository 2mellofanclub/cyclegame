extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := true
var players = []
var enemies = []
var recognizers = []
var allies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.spawns_requested.emit()
	await get_tree().create_timer(3).timeout
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
	if "take_dmg" in body:
		body.take_dmg(10000.0)
func _on_despawn_box_body_entered(body: Node3D) -> void:
	body.queue_free()
