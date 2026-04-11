shader_type canvas_item;

uniform float tilt_x : hint_range(-1.0, 1.0) = 0.0;
uniform float tilt_y : hint_range(-1.0, 1.0) = 0.0;
uniform float shadow_strength = 0.3;
uniform float highlight_strength = 0.5;

void fragment() {
    vec2 uv = UV;

    // --- 1. 伪3D倾斜 ---
    vec2 centered = uv - 0.5;
    centered.x += tilt_x * (centered.y);
    centered.y += tilt_y * (centered.x);
    uv = centered + 0.5;

    vec4 color = texture(TEXTURE, uv);

    // --- 2. 边缘暗（厚度感）---
    float dist = distance(uv, vec2(0.5));
    float vignette = smoothstep(0.7, 0.3, dist);
    color.rgb *= mix(1.0 - shadow_strength, 1.0, vignette);

    // --- 3. 高光（类似卡面反光）---
    float light = dot(normalize(vec3(tilt_x, tilt_y, 1.0)), vec3(0.0, 0.0, 1.0));
    color.rgb += highlight_strength * light;

    COLOR = color;
}