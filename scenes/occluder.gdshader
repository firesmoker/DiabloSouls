shader_type canvas_item;

uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    COLOR.a *= shadow_intensity;
	}