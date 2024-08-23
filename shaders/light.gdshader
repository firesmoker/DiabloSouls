shader_type canvas_item;


// 040012
uniform vec3 color: source_color = vec3(1.0);
uniform float power: hint_range(0.0, 6.0, 0.1) = 3.0;
uniform float radius: hint_range(0.0, 10.0, 0.1) = 2.5;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;


void fragment() {
	vec2 uv = UV;
	float distance_from_center = length(vec2(abs(uv.x - 0.5), abs(uv.y - 0.5)));
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = screen_color.rgb * vec3(1.0 + power + 1.0 - length(color)) * color;
	COLOR.a = 1.0 - distance_from_center * (1.0 / (radius * 0.1));
}