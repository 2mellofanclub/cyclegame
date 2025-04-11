extends MeshInstance3D

var material_set := false
var surf_material : ShaderMaterial
var d_dots : Node3D


func _process(delta):
	if material_set:
		var points_to_pass = []
		for d_dot in d_dots.get_children():
			points_to_pass.append(d_dot.get_global_position())
		surf_material.set_shader_parameter("dmg_points", points_to_pass)
