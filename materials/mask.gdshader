shader_type spatial; 
uniform vec3 Cpoint;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
varying vec3 glo_vertex;

void vertex() {
	// Fine. We'll do it your way Pixezy.
	glo_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	if(distance(Cpoint, glo_vertex) < 0.9) discard;
	EMISSION = (emission.rgb) * emission_energy;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
