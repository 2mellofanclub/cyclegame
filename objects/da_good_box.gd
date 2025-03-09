extends MeshInstance3D

var cpoint = null
var using_shader = true


func _process(delta):
	if using_shader and not cpoint == null:
		get_surface_override_material(0).set_shader_parameter("Cpoint", cpoint)
