shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 outline_color: source_color = vec4(1.0, 0.84, 0.0, 1.0);
uniform float line_thickness: hint_range(0.0, 10.0) = 8.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	if (enabled) {
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
		float alpha = col.a;
		
		// Sample surrounding pixels to detect edges
		alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, -size.y)).a);
		alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
		alpha = max(alpha, texture(TEXTURE, UV + vec2(-size.x, 0.0)).a);
		alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);
		
		if (col.a < 0.1 && alpha > 0.1) {
			COLOR = outline_color;
		} else {
			COLOR = col;
		}
	} else {
		COLOR = col;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
