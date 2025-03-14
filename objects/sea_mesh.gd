extends MeshInstance3D

var shader_material

func _ready() -> void:
	shader_material = get_surface_override_material(0)

func _process(delta: float) -> void:
	var secs = Time.get_ticks_msec() / 50000.0
	shader_material.set_shader_parameter("sinpan", sin(secs))
	shader_material.set_shader_parameter("cospan", cos(secs))
