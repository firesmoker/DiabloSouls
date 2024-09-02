shader_type canvas_item;


// 040012
uniform vec3 color: source_color = vec3(1.0);
uniform float power: hint_range(0.0, 6.0, 0.1) = 3.0;
uniform float radius: hint_range(0.0, 10.0, 0.1) = 5.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform bool flickering = false;
uniform float flicker_range: hint_range(1.0, 5.0, 0.1) = 1.0;


float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	float distance_from_center = length(vec2(abs(uv.x - 0.5), abs(uv.y - 0.5)));
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float random_radius = radius;
	if (flickering) {
		random_radius = clamp(sin(TIME * 50.0) * radius, radius * 0.95, radius);
		random_radius *= (1.0 - 0.2 * abs(cos(TIME * 30.0)));
	}
	float new_power = 2.6;
	random_radius = 2.3;
	COLOR.rgb = screen_color.rgb * vec3(1.0 + new_power + 1.0 - length(color)) * color;
	COLOR.a = 1.0 - distance_from_center * (1.0 / (random_radius *  0.1)) + clamp((1.0 - distance_from_center), 0.0, 1.0) / 1.0;
}

