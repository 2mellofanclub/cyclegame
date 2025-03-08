extends Node3D

var colors = {
	"blue" : "res://materials/lw_blue1.tres",
	"green" : "res://materials/lw_green1.tres",
	"orange" : "res://materials/lw_orange1.tres",
}

func prepare(color):
	var material = load(colors[color])
	$BodyDebris/lc_body_deb3/lattice.set_surface_override_material(0, material)
	$Wheel/lc_wheel/Wheel.set_surface_override_material(1, material)
	$Wheel2/lc_wheel/Wheel.set_surface_override_material(1, material)
	var Cube = load("res://destruction/cube.tscn")
	for i in range(0, randi_range(20, 50)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, material)
		add_child(cube_instance)
		
