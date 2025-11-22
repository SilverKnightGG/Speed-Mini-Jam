shader_type canvas_item;

render_mode blend_add;

uniform sampler2D front_texture : repeat_enable;
uniform sampler2D bg_texture0 : repeat_enable;
uniform sampler2D bg_texture1 : repeat_enable;

uniform float speed_front;
uniform float speed_bg0;
uniform float speed_bg1;

uniform float y_offset : hint_range(-0.2, 0.2, 0.001);
uniform float x_offset : hint_range(-0.2, 0.2, 0.001);


void fragment() {
	
	vec4 front_pixels = texture(front_texture, vec2(UV.x + x_offset + TIME * speed_front, UV.y + y_offset));
	vec4 bg0_pixels = texture(bg_texture0, vec2(UV.x + x_offset + TIME * speed_bg0, UV.y + y_offset));
	vec4 bg1_pixels = texture(bg_texture1, vec2(UV.x + x_offset + TIME * speed_bg1, UV.y + y_offset));
	
	vec4 background = mix(bg0_pixels, bg1_pixels, 0.5);
	
	COLOR = background / front_pixels;
	COLOR.a *= 0.09;
	
	}







	//