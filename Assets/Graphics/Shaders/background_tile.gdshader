shader_type canvas_item;


uniform sampler2D front_texture : repeat_enable;
uniform sampler2D bg_texture0 : repeat_enable;
uniform sampler2D bg_texture1 : repeat_enable;

uniform float speed_front;
uniform float speed_bg0;
uniform float speed_bg1;


void fragment() {
	
	vec4 front_pixels = texture(front_texture, vec2(UV.x + TIME * speed_front, UV.y));
	vec4 bg0_pixels = texture(bg_texture0, vec2(UV.x + TIME * speed_bg0, UV.y));
	vec4 bg1_pixels = texture(bg_texture1, vec2(UV.x + TIME * speed_bg1, UV.y));
	
	vec4 background = mix(bg0_pixels, bg1_pixels, 0.5);
	
	COLOR = background / front_pixels;
	COLOR.a *= 0.09;
	
	}







	//