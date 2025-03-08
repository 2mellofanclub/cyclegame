extends Node3D

var materials = {
	"body":"res://materials/badguy_black1.tres",
	"wheelwells":"res://materials/lw_blue1.tres",
	"lwbase":"res://materials/lw_blue1.tres",
	"lwpulse":"res://materials/lw_blue1_pulse.tres",
	"lattice":"res://materials/lw_blue1.tres",
}

func prepare():
	$BodyDebris/lc_body_deb3/lattice.set_surface_override_material(0, load(materials["lattice"]))
	$BodyDebris/lc_body_deb3/shell.set_surface_override_material(1, load(materials["body"]))
	$Wheel/lc_wheel/Wheel.set_surface_override_material(1, load(materials["wheelwells"]))
	$Wheel2/lc_wheel/Wheel.set_surface_override_material(1, load(materials["wheelwells"]))
	var Cube = load("res://destruction/cube.tscn")
	for i in range(0, randi_range(50, 70)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, load(materials["lattice"]))
		add_child(cube_instance)
		
