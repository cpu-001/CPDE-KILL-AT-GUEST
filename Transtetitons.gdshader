shader_type canvas_item;

void fragment() {
	float a = UV.y;
	COLOR = vec4(0.0, 0.0, 0.0, a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
