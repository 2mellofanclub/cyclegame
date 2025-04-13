shader_type spatial;
uniform vec3 enemy_pos = vec3(0.0, 9999.0, 0.0);
uniform vec4 emission : source_color;
uniform vec4 albedo : source_color;
//uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
varying float emission_energy;
varying vec3 glo_vertex;

void vertex() {
	// Fine Pixezy, We'll do it your way.
	glo_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	//if((log(distance(enemy_pos, glo_vertex)) / log(1000)) < 0.66) emission_nrg_mult = 1.0;
	emission_energy = 16.0 - 2.0 * log2(distance(enemy_pos, glo_vertex));
	if (emission_energy < 0.0) emission_energy = 0.0;
	EMISSION = (emission.rgb) * emission_energy;
	ALBEDO = albedo.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
