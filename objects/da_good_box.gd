extends MeshInstance3D

var cpoint = null
var dcpoint = null
var using_shader = true
var shader_material

func _ready() -> void:
	shader_material = get_surface_override_material(0)


func _process(_delta):
	if using_shader and not cpoint == null:
		shader_material.set_shader_parameter("Cpoint", cpoint)
		shader_material.set_shader_parameter("DCpoint", dcpoint)
