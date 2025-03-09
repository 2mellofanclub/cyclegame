extends MeshInstance3D

var cpoint = null

func _process(delta):
	if not cpoint == null:
		get_surface_override_material(0).set_shader_parameter("Cpoint", cpoint)
