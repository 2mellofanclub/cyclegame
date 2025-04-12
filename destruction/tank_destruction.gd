extends Node3D

var tank_color := ""
var tank_materials = MaterialsBus.TANK_STYLES
@onready var Cube = load("res://destruction/cube.tscn")

func prepare():
	$TurretDebris/Turretbase.set_surface_override_material(0, tank_materials[tank_color]["turret"])
	$TurretDebris/Turretbase.set_surface_override_material(1, tank_materials[tank_color]["upper_radar"])
	$TurretDebris/Turretbase.set_surface_override_material(2, tank_materials[tank_color]["lower_radar"])
	$TurretDebris/Turretbase/Turretbarrel.set_surface_override_material(0, tank_materials[tank_color]["barrel"])
	$TurretDebris/Turretbase/Turretbarrel.set_surface_override_material(1, tank_materials[tank_color]["muzzle"])
	for i in range(0, randi_range(50, 70)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, tank_materials[tank_color]["lattice"])
		$Cubes.add_child(cube_instance)
