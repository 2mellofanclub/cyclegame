shader_type spatial;
uniform vec4 emission : source_color;
uniform vec4 albedo : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
uniform float height_scale;
uniform float sinpan;
uniform float cospan;
uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;


void vertex() {
	tex_position = vec2(VERTEX.x + sinpan, VERTEX.z + cospan);
	float height = texture(noise, tex_position).x;
	VERTEX.y += height * height_scale;
}
void fragment() {
	EMISSION = (emission.rgb) * emission_energy;
	ALBEDO = albedo.rgb;
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
