extends RigidBody3D


var damage := 0.0
var exploded := false
var out_of_muzzle := false
var gunner : VehicleBody3D
var shot_color := ""
var tank_styles = MaterialsBus.TANK_STYLES

@onready var Cube = load("res://destruction/cube.tscn")

func _ready() -> void:
	set_use_continuous_collision_detection(true)


func _process(delta):
	if exploded:
		return
	if $ImpactRay.is_colliding():
		if $ImpactRay.get_collider().name != "RBTankShot":
			if "take_hit" in $ImpactRay.get_collider():
				$ImpactRay.get_collider().take_hit($ImpactRay.get_collision_point(), damage)
			explode()


func explode():
	if exploded:
		return
	exploded = true
	set_linear_velocity(Vector3.ZERO)
	$HitShape.queue_free()
	freeze = true
	$ShotMesh.hide()
	for i in range(0, randi_range(5, 10)):
		var cube_instance = Cube.instantiate()
		cube_instance.get_child(0).set_surface_override_material(0, tank_styles[shot_color]["shot"])
		add_child(cube_instance)
		cube_instance.apply_impulse(
				Vector3(
					randi_range(-10, 10),
					randi_range(10, 20),
					randi_range(-10, 10)
				)
		)

func apply_materials():
	$ShotMesh.set_surface_override_material(0, tank_styles[shot_color]["shot"])

func _on_timer_timeout() -> void:
	queue_free()


func _on_muzzle_timer_timeout() -> void:
	out_of_muzzle = true
