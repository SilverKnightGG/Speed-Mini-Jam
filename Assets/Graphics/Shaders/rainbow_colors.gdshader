shader_type canvas_item;

render_mode blend_add;

// --- Uniforms --- /
uniform float influence: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float offset: hint_range(0.0, 360.0, 1.0);

uniform float speed : hint_range(0.1, 5.0, 0.1);

const float TWO_PI = 6.28318530718;

// --- Functions --- //
vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	COLOR.rgb += influence * hsv2rgb(vec3(((atan(pos.y, pos.x) + radians(offset * cos(TIME * speed))) / TWO_PI) + 0.5, length(pos) * 2.0, 1.0));
}