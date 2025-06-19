shader_type sky;


uniform vec3 sky_color : source_color;
uniform vec3 hor_color : source_color;
uniform sampler2D sky_tex;


void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	COLOR = texture(sky_tex, SKY_COORDS).rgb * 3.0;


}
