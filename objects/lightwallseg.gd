extends Node3D


var hot = false
var using_shader = true
var Driver
var lc_materials = MaterialsBus.LC_MATERIALS
var lw_color = ""


func is_hot():
	return hot
func heat():
	hot = true
func cool():
	hot = false



func _ready():
	hide()


# change how and when materials are received, i.e. from mbus upon instantiation
func _process(delta):
	if Driver == null:
		return
	$Shell/DaGoodBox.cpoint = Driver.get_node("IDunno/TrailEater").get_global_position()
	if not visible:
		if global_position.distance_to(Driver.get_global_position()) > 2.1:
			$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["slwbase"])
			show()
	elif not hot:
		if global_position.distance_to(Driver.get_global_position()) > 3.5:
			heat()
	elif using_shader:
		if global_position.distance_to(Driver.get_global_position()) > 6:
			using_shader = false
			$Shell/DaGoodBox.using_shader = false
			$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["lwbase"])



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
	if using_shader:
		$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["slwpulse"])
		await get_tree().create_timer(0.1).timeout
		$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["slwbase"])
	else:
		$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["lwpulse"])
		await get_tree().create_timer(0.1).timeout
		$Shell/DaGoodBox.set_surface_override_material(0, lc_materials[lw_color]["lwbase"])
