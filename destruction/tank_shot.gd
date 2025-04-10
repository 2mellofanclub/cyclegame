extends Node3D


var exploded := false
var muzzle_vel := 100.0
var cycle_color := ""
var lc_styles = MaterialsBus.LC_STYLES

@onready var Cube = load("res://destruction/cube.tscn")


func _process(delta):
	if exploded:
		return
	transform = transform.translated_local(Vector3(0,0,-1) * muzzle_vel * delta)


func explode():
	if exploded:
		return
	exploded = true
	$ShotMesh.hide()
	for i in range(0, randi_range(10, 20)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, lc_styles[cycle_color]["lattice"])
		add_child(cube_instance)
		cube_instance.apply_impulse(
				Vector3(
					randi_range(-10, 10),
					randi_range(10, 20),
					randi_range(-10, 10)
				)
		)

func apply_materials():
	$ShotMesh.set_surface_override_material(0, lc_styles[cycle_color]["lattice"])

func _on_timer_timeout() -> void:
	queue_free()


func _on_hit_box_area_entered(area: Area3D) -> void:
	explode()
	print("area")

func _on_hit_box_body_entered(body: Node3D) -> void:
	explode()
	print("body")
