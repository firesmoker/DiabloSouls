shader_type canvas_item;
//uniform vec2 dir = vec2(0,0);
uniform float dir_x: hint_range(0.0, 0.05, 0.005);
uniform float dir_y: hint_range(0.0, 0.05, 0.005);
uniform int quality = 4;

void vertex(){
	vec2 dir = vec2(dir_x, dir_y);
	vec2 blurSize = abs(dir) * 2.0;
	VERTEX *= blurSize + 1.0;
	UV = (UV - 0.5) * (blurSize + 1.0) + 0.5;
}

float insideUnitSquare(vec2 v) {
    vec2 s = step(vec2(0.0), v) - step(vec2(1.0), v);
    return s.x * s.y;
}

void fragment(){
	vec2 dir = vec2(dir_x, dir_y);
	float inSquare = insideUnitSquare(UV);
	float numSamples = inSquare;
	COLOR = texture(TEXTURE, UV) * inSquare;
	vec2 stepSize = dir/(float(quality));
	vec2 uv;
	for(int i = 1; i <= quality; i++){
		uv = UV + stepSize * float(i);
		inSquare = insideUnitSquare(uv);
		numSamples += inSquare;
		COLOR += texture(TEXTURE, uv) * inSquare;

		uv = UV - stepSize * float(i);
		inSquare = insideUnitSquare(uv);
		numSamples += inSquare;
		COLOR += texture(TEXTURE, uv) * inSquare;
	}
	COLOR.rgb /= numSamples;
	COLOR.a /= float(quality)*2.0 + 1.0;
}



//
//shader_type canvas_item;
//
//uniform float width: hint_range(0.0, 30.0) = 0.0;
//uniform vec4 modulated_color: source_color = vec4(1, 1, 1, 1);
//uniform vec4 outline_color: source_color = vec4(0, 1, 0, 1);
//
//
//void fragment() {
	//float size = width * 1.0 / float(textureSize(TEXTURE, 0).x);
	//vec4 sprite_color = texture(TEXTURE, UV);
	//float alpha = -4.0 * sprite_color.a;
	//alpha += texture(TEXTURE, UV + vec2(size, 0.0)).a;
	//alpha += texture(TEXTURE, UV + vec2(-size, 0.0)).a;
	//alpha += texture(TEXTURE, UV + vec2(0.0, size)).a;
	//alpha += texture(TEXTURE, UV + vec2(0.0, -size)).a;
//
	//vec4 final_color = mix(sprite_color * modulated_color, outline_color, clamp(alpha, 0.0, 1.0));
	//COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
//
//}