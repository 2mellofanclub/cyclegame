shader_type spatial;
uniform vec3 enemy_pos;
uniform vec4 emission : source_color;
uniform vec4 albedo : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
varying vec3 glo_vertex;

void vertex() {
	// Fine Pixezy, We'll do it your way.
	glo_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	float multiplier = 1.0;
	if((log(distance(enemy_pos, glo_vertex)) / log(500)) < 0.7) multiplier = 2.0;
	EMISSION = (emission.rgb) * emission_energy * multiplier;
	ALBEDO = albedo.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
