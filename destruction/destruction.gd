extends Node3D

var cycle_color := ""
var lc_styles = MaterialsBus.LC_STYLES
@onready var Cube = load("res://destruction/cube.tscn")

func prepare():
	$BodyDebris/lc_body_deb4/lattice.set_surface_override_material(0, lc_styles[cycle_color]["lattice"])
	$BodyDebris/lc_body_deb4/shell.set_surface_override_material(1, lc_styles[cycle_color]["body0"])
	$Wheel/lc_wheel2/Frontwheel.set_surface_override_material(1, lc_styles[cycle_color]["wheelwells"])
	$Wheel2/lc_wheel2/Frontwheel.set_surface_override_material(1, lc_styles[cycle_color]["wheelwells"])
	for i in range(0, randi_range(50, 70)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, lc_styles[cycle_color]["lattice"])
		add_child(cube_instance)
