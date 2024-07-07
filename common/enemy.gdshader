shader_type spatial;
render_mode unshaded;

uniform float time = 0.0;
uniform float health : hint_range(0.0, 1.0) = 1.0;
uniform float scale = 1.0;
uniform vec2 bullet_hole_position = vec2(0.5);
uniform float bullet_hit_at = -1000.0;

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
	float t = TIME;
	ALBEDO = vec3(0.0);
	vec2 pos1 = vec2(sin(2.0 * 1.0 * t + 10.0) * 0.5 * 0.4, cos(0.3 * 1.0 * t + 20.0) * 1.5 * 0.1) + 0.5;
	vec2 pos2 = vec2(sin(2.0 * 1.0 * t + 30.0) * 0.5 * 0.4, cos(0.3 * 2.0 * t + 40.0) * 1.5 * 0.25) + 0.5;
	vec2 pos3 = vec2(sin(2.0 * 2.0 * t + 50.0) * 0.5 * 0.4, cos(0.3 * 1.0 * t + 60.0) * 1.5 * 0.05) + 0.5;
	vec2 pos4 = vec2(sin(2.0 * 2.0 * t + 70.0) * 0.5 * 0.4, cos(0.3 * 2.0 * t + 80.0) * 1.5 * 0.05) + 0.5;
	vec2 pos5 = vec2(sin(2.0 * 2.0 * t + 90.0) * 0.5 * 0.4, cos(0.3 * 2.0 * t + 100.0) * 1.5 * 0.05) + 0.5;
	vec2 pos6 = vec2(sin(2.0 * 2.0 * t + 110.0) * 0.5 * 0.4, cos(0.3 * 2.0 * t + 120.0) * 1.5 * 0.05) + 0.5;
	vec2 pos7 = vec2(sin(2.0 * 1.0 * t + 130.0) * 0.5 * 0.4, cos(0.3 * 8.0 * t + 140.0) * 1.5 * 0.2) + 0.5;
	vec2 pos8 = vec2(sin(2.0 * 1.0 * t + 150.0) * 0.5 * 0.4, cos(0.3 * 7.0 * t + 160.0) * 1.5 * 0.25) + 0.5;
	vec2 pos9 = vec2(sin(2.0 * 2.0 * t + 170.0) * 0.5 * 0.4, cos(0.3 * 6.0 * t + 180.0) * 1.5 * 0.05) + 0.5;
	vec2 pos10 = vec2(sin(2.0 * 2.0 * t + 190.0) * 0.5 * 0.4, cos(0.3 * 3.0 * t + 200.0) * 1.5 * 0.05) + 0.5;
	vec2 pos11 = vec2(sin(2.0 * 2.0 * t + 210.0) * 0.5 * 0.4, cos(0.3 * 4.0 * t + 220.0) * 1.5 * 0.05) + 0.5;
	vec2 pos12 = vec2(sin(2.0 * 2.0 * t + 230.0) * 0.5 * 0.4, cos(0.3 * 5.0 * t + 240.0) * 1.5 * 0.05) + 0.5;
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
	float blob_sdf = smoothstep(0.0, pixel_size * 10.0, sum - blobiness);
	ALPHA = clamp(blob_sdf, 0.0, 1.0);
}