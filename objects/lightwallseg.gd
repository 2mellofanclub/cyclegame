extends Node3D


var hot = false
var Driver
var materials = {}


func is_hot():
	return hot
func heat():
	hot = true
func cool():
	hot = false



func _ready():
	hide()


func _process(delta):
	if not Driver == null:
		$Shell/DaGoodBox.cpoint = Driver.get_node("TrailEater").get_global_position()
		if not visible:
			if global_position.distance_to(Driver.get_global_position()) > 2:
				#$Shell/DaGoodBox.set_surface_override_material(0, load(materials["lwbase"]))
				show()
		if not hot:
			if global_position.distance_to(Driver.get_global_position()) > 3.5:
				heat()



func _on_lightarea_body_entered(body):
	if not hot:
		return
	if "explode" in body:
		# move these checks to explode? (and have explode() return bool)
		if body.is_alive() and body.is_explodable():
			print("ka")
			body.explode()


func _on_timer_timeout() -> void:
	queue_free()


func _on_lightosci_timeout() -> void:
	$Shell/DaGoodBox.set_surface_override_material(0, load(materials["lwpulse"]))
	await get_tree().create_timer(0.1).timeout
	$Shell/DaGoodBox.set_surface_override_material(0, load(materials["lwbase"]))
