shader_type spatial;
uniform float pulse_offset;
uniform float pulse_band_offset;
uniform vec4 emission : source_color;
uniform vec4 albedo : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
varying float emission_nrg_mult;
varying vec3 glo_vertex;
varying float gz;
varying float gx;

void vertex() {
	// Fine Pixezy, We'll do it your way.
	glo_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	gz = glo_vertex.z;
	gx = glo_vertex.x;
}
void fragment() {
	emission_nrg_mult = 1.0;
	if(
		 (gx > -pulse_band_offset &&
		 gx < pulse_band_offset &&
		 gz > pulse_offset &&
		 gz < (pulse_offset+2.0)) ||
		(gx > -pulse_band_offset &&
		 gx < pulse_band_offset &&
		 gz < -pulse_offset &&
		 gz > (-pulse_offset-2.0)) ||
		(gz > -pulse_band_offset &&
		 gz < pulse_band_offset &&
		 gx > pulse_offset &&
		 gx < (pulse_offset+2.0)) ||
		(gz > -pulse_band_offset &&
		 gz < pulse_band_offset &&
		 gx < -pulse_offset &&
		 gx > (-pulse_offset-2.0))
	) emission_nrg_mult = 2.0;
	EMISSION = (emission.rgb) * emission_energy * emission_nrg_mult;
	ALBEDO = albedo.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
