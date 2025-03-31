/**********************************
 *
 * Axolotl Face: Axolotl with eyes closing based on battery level
 *
 **********************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform float battery;
uniform int nightMode;
uniform float time;
uniform vec2 offset;

const float PI = 3.14159;
//const float battery = 0.3;

const vec2 EYE_RADII = vec2(80, 100);
const vec2 EYELID_RADII = vec2(2.0 * EYE_RADII.x, EYE_RADII.y);
const float EYE_THICKNESS = 10.0;
const float EYE_SEP = 700.0;

const vec2 CHEEK_RADII = vec2(50, 50);
const float CHEEK_SEP = 800.0;

const float MOUTH_HEIGHT = 10.0;
const float MOUTH_LEN = 300.0;

const vec4 BLACK = vec4(0, 0, 0, 255) / 255.0;
const vec4 LIGHT_PINK = vec4(255, 145, 204, 255) / 255.0;
const vec4 PINK = vec4(255, 97, 181, 255) / 255.0;
const vec4 DARK_PINK = vec4(139, 0, 83, 255) / 255.0;

const vec4 LIGHT_BROWN = vec4(93, 42, 44, 255) / 255.0;
const vec4 BROWN = vec4(91, 22, 23, 255) / 255.0;

bool ellipse(vec2 uv, vec2 pos, vec2 radii) {
	bool inner = length((uv - pos) / radii) <= 1.0;

	return inner;
}

bool ellipse(vec2 uv, vec2 pos, vec2 radii, float thickness) {
	vec2 t = vec2(thickness) / 2.0;
	bool inner = ellipse(uv, pos, radii - t);
	bool outer = ellipse(uv, pos, radii + t);

	return !inner && outer;
}

bool eyes(vec2 uv, vec2 center) {
	vec2 x_sep = vec2(EYE_SEP / 2.0, 0.0);
	vec2 lid_shift = vec2(0.0, 10.0 * sin(2.0 * PI / 3.0 * time) + battery * 2.0 * EYE_RADII.y);

	bool left = ellipse(uv, center - x_sep, EYE_RADII);
	bool right = ellipse(uv, center + x_sep, EYE_RADII);

	bool left_lid = ellipse(uv, center - x_sep + lid_shift, EYELID_RADII);
	bool right_lid = ellipse(uv, center + x_sep + lid_shift, EYELID_RADII);

	return (left || right) && !(left_lid || right_lid);
}

bool cheeks(vec2 uv, vec2 center) {
	vec2 x_sep = vec2(CHEEK_SEP / 2.0, 0);
	vec2 y_shift = vec2(0, -2.0 * EYE_RADII.y);

	bool left = ellipse(uv, center - x_sep + y_shift, CHEEK_RADII);
	bool right = ellipse(uv, center + x_sep + y_shift, CHEEK_RADII);

	return left || right;
}

bool mouth(vec2 uv, vec2 center) {
	vec2 local_uv = uv - center;
	if (abs(local_uv.x) > MOUTH_LEN / 2.0) {
		return false;
	}

	float wave = MOUTH_HEIGHT * cos(2.0 * PI * 1.5 / MOUTH_LEN * local_uv.x);
	return abs(wave - (uv.y - center.y + EYE_RADII.y)) < 10.0;
}

float bg_length(vec2 v) {
	const float N = 4.0;
	return pow(pow(v.x, N) + pow(v.y, N), 1.0/N);
}

void main(void) {
	vec2 scale = vec2(1080, 2400) / resolution;
	vec2 uv = gl_FragCoord.xy * scale;
	vec2 CENTER = resolution / 2.0;

	CENTER.x += 300.0 * (0.5 - offset);

	vec4 bg;
	vec4 eye_col;
	vec4 cheek_col;
	vec4 mouth_col;

	if (nightMode == 1) {
		bg = (bg_length(uv - CENTER) < 530.0) ? BLACK : BLACK;
	} else {
		bg = LIGHT_PINK;
	}

	eye_col = BROWN;
		cheek_col = PINK;
		mouth_col = DARK_PINK;

	if (eyes(uv, CENTER))
		gl_FragColor = eye_col;
	else if (cheeks(uv, CENTER))
		gl_FragColor = cheek_col;
	else if (mouth(uv, CENTER))
		gl_FragColor = mouth_col;
	else
		gl_FragColor = bg;

}
