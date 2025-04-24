extends MeshInstance3D

var cpoint = null
var dcpoint = null
var using_shader = true
var shader_material

func _ready() -> void:
	pass


func _process(_delta):
	if using_shader and not cpoint == null:
		shader_material = get_surface_override_material(0)
		shader_material.set_shader_parameter("Cpoint", cpoint)
		shader_material.set_shader_parameter("DCpoint", dcpoint)


func _on_light_osci_timeout() -> void:
	if using_shader:
		get_surface_override_material(0).set_shader_parameter("emission_energy", 16.0)
		await get_tree().create_timer(0.1).timeout
		get_surface_override_material(0).set_shader_parameter("emission_energy", 10.0)
	else:
		get_surface_override_material(0).emission_energy_multiplier = 16.0
		await get_tree().create_timer(0.1).timeout
		get_surface_override_material(0).emission_energy_multiplier = 10.0
