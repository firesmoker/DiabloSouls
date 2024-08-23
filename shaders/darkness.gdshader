shader_type canvas_item;


// 040012
uniform vec3 color: source_color = vec3(1);
uniform float transparency: hint_range(0.0, 1.0, 0.1);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;


void fragment() {
	//vec4 screen_color = texture(SCRE)
	//SCREEN_UV
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = screen_color.rgb * color;
	//COLOR.r = COLOR.r + 0.3;
	//COLOR.rgb = color;
	COLOR.a = transparency;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
