shader_type spatial;
render_mode unshaded;

uniform float time = 0.0;
uniform float health : hint_range(0.0, 1.0) = 1.0;
uniform float scale = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
}

float field(vec2 pos, float radius, vec2 uv) {
	return radius / distance(pos, uv);
}

void fragment() {
	float size = mix(0.05, 0.08, health);
	float blobiness = mix(4.0, 3.0, health);
	ALBEDO = vec3(0.0);
	vec2 pos1 = vec2(sin(2.0 * 1.0 * time + 10.0) * 0.5 * 0.4, cos(0.3 * 1.0 * time + 20.0) * 1.5 * 0.1) + 0.5;
	vec2 pos2 = vec2(sin(2.0 * 1.0 * time + 30.0) * 0.5 * 0.4, cos(0.3 * 2.0 * time + 40.0) * 1.5 * 0.25) + 0.5;
	vec2 pos3 = vec2(sin(2.0 * 2.0 * time + 50.0) * 0.5 * 0.4, cos(0.3 * 1.0 * time + 60.0) * 1.5 * 0.05) + 0.5;
	vec2 pos4 = vec2(sin(2.0 * 2.0 * time + 70.0) * 0.5 * 0.4, cos(0.3 * 2.0 * time + 80.0) * 1.5 * 0.05) + 0.5;
	vec2 pos5 = vec2(sin(2.0 * 2.0 * time + 90.0) * 0.5 * 0.4, cos(0.3 * 2.0 * time + 100.0) * 1.5 * 0.05) + 0.5;
	vec2 pos6 = vec2(sin(2.0 * 2.0 * time + 110.0) * 0.5 * 0.4, cos(0.3 * 2.0 * time + 120.0) * 1.5 * 0.05) + 0.5;
	vec2 pos7 = vec2(sin(2.0 * 1.0 * time + 130.0) * 0.5 * 0.4, cos(0.3 * 8.0 * time + 140.0) * 1.5 * 0.2) + 0.5;
	vec2 pos8 = vec2(sin(2.0 * 1.0 * time + 150.0) * 0.5 * 0.4, cos(0.3 * 7.0 * time + 160.0) * 1.5 * 0.25) + 0.5;
	vec2 pos9 = vec2(sin(2.0 * 2.0 * time + 170.0) * 0.5 * 0.4, cos(0.3 * 6.0 * time + 180.0) * 1.5 * 0.05) + 0.5;
	vec2 pos10 = vec2(sin(2.0 * 2.0 * time + 190.0) * 0.5 * 0.4, cos(0.3 * 3.0 * time + 200.0) * 1.5 * 0.05) + 0.5;
	vec2 pos11 = vec2(sin(2.0 * 2.0 * time + 210.0) * 0.5 * 0.4, cos(0.3 * 4.0 * time + 220.0) * 1.5 * 0.05) + 0.5;
	vec2 pos12 = vec2(sin(2.0 * 2.0 * time + 230.0) * 0.5 * 0.4, cos(0.3 * 5.0 * time + 240.0) * 1.5 * 0.05) + 0.5;
	float sum = field(pos1, size, UV)
		+ field(pos2, size, UV)
		+ field(pos3, size, UV)
		+ field(pos4, size, UV)
		+ field(pos4, size, UV)
		+ field(pos6, size, UV)
		+ field(pos7, size, UV)
		+ field(pos8, size, UV)
		+ field(pos9, size, UV)
		+ field(pos10, size, UV)
		+ field(pos11, size, UV)
		+ field(pos12, size, UV)
		+ field(vec2(0.5), 0.25, UV);
	float pixel_size = 1.0 / VIEWPORT_SIZE.y;
	ALPHA = smoothstep(blobiness, blobiness + pixel_size * 10.0, sum);
}