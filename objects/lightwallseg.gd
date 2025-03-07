extends Node3D


var hot = false
var Player


func is_hot():
	return hot
func heat():
	hot = true
func cool():
	hot = false


func _ready():
	hide()


func _process(delta):
	if not hot:
		if not Player == null:
			if global_position.distance_to(Player.get_global_position()) > 4:
				heat()
				show()


func _on_lightarea_body_entered(body):
	if not hot:
		return
	if body.name == "Player":
		if body.is_alive() and body.is_explodable():
			print("ka")
			body.explode()


func _on_timer_timeout() -> void:
	queue_free()


func _on_lightosci_timeout() -> void:
	var original_material = $Shell/Wall1.get_surface_override_material(0)
	var pulse_material = load("res://materials/lw_blue1_pulse.tres")
	for wall in $Shell.get_children():
		wall.set_surface_override_material(0, pulse_material)
	await get_tree().create_timer(0.1).timeout
	for wall in $Shell.get_children():
		wall.set_surface_override_material(0, original_material)
