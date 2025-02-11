shader_type canvas_item;

uniform float brightness: hint_range(-1.0, 1.0) = 0.0;
uniform float contrast: hint_range(0.0, 2.0) = 1.0;
uniform float saturation: hint_range(0.0, 2.0) = 1.0;
uniform vec3 tint: source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    
    // Apply brightness
    vec4 color = original_color + vec4(brightness, brightness, brightness, 0.0);
    
    // Apply contrast
    color.rgb = ((color.rgb - 0.5) * contrast + 0.5);
    
    // Apply saturation
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(gray), color.rgb, saturation);
    
    // Apply tint
    color.rgb *= tint;
    
    COLOR = color;
}
