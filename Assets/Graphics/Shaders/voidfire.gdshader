shader_type canvas_item;

render_mode blend_add;

uniform float timeScaleFactor = .04;

// edge span
uniform float edge_size : hint_range(0.000, 1.0, 0.0001) = 0.2;
uniform float edge_fade : hint_range(0.000, 1.0, 0.001) = 0.2;
uniform float edge_start : hint_range(0.0, 1.0, 0.01) = 1.0;

// User-controlled colors
uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;

// A direction vector (normalized or not) that defines the flow angle
uniform vec2 angle_vector = vec2(-1.0, 0.0);

// Seamless noise
uniform sampler2D noise_texture : repeat_enable, filter_linear;

float localTime() {
    return TIME * timeScaleFactor;
}

// Converts a direction vector to a rotation matrix
mat2 angle_matrix(vec2 dir) {
    // normalize to avoid distortion
    vec2 n = normalize(dir);
    return mat2(vec2(n.x, -n.y), vec2(n.y, n.x));
}

mat2 makem2(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(vec2(c, -s), vec2(s, c));
}

float noise(vec2 x) {
    return texture(noise_texture, x * .01).x;
}

vec2 gradn(vec2 p) {
    float ep = .09;
    float gradx = noise(vec2(p.x + ep, p.y)) - noise(vec2(p.x - ep, p.y));
    float grady = noise(vec2(p.x, p.y + ep)) - noise(vec2(p.x, p.y - ep));
    return vec2(gradx, grady);
}

float flow(vec2 p) {
    float z = 2.;
    float rz = 0.;
    vec2 bp = p;

    for (float i = 1.; i < 7.; ++i) {
        p += localTime() * .6;
        bp += localTime() * 1.9;

        vec2 gr = gradn(i * p * .34 + localTime() * 1.);
        gr *= makem2(localTime() * 6. - (.05 * p.x + 0.03 * p.y) * 40.);
        p += gr * .5;

        rz += (sin(noise(p) * 7.) * .5 + .5) / z;

        p = mix(bp, p, .77);
        z *= 1.4;
        p *= 2.;
        bp *= 1.9;
    }
    return rz;
}

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;

    // Standardize coords
    vec2 fragCoord = FRAGCOORD.xy;
    fragCoord.y = resolution.y - fragCoord.y;
    vec2 p = fragCoord / resolution - 0.5;

    // Aspect correct + scaling
    p.x *= resolution.x / resolution.y;
    p *= 3.0;

    // --- Apply user angle here ---
    p = angle_matrix(angle_vector) * p;

    // Flow field
    float rz = flow(p);

    // --- Replace hardcoded burn colors with user colors ---
    // original: col = vec3(.2, .07, .01) / rz;
    vec3 base = mix(color1, color2, rz);   // fades between color1 → color2
    vec3 col = base / rz;

    col = pow(col, vec3(1.4));
	
	float edge_mask = smoothstep(edge_start, edge_start - (edge_size + 0.000001), UV.x);
	float burn_mask = smoothstep(edge_start, edge_start - (edge_fade + 0.000001), edge_start - (((col.r + col.g + col.b) / 3.0) * edge_mask));
	float alpha = burn_mask * edge_mask;
	
	if (burn_mask > 0.1) {
		float gap = edge_start - edge_size;
		alpha = UV.x + gap;
		
		if (UV.x < edge_start - edge_size) {
			alpha = 1.0;
			}
		else {
			alpha = smoothstep(0.0, 1.0, edge_start - UV.x);
			}
		}

    COLOR = vec4(col, alpha);
}
