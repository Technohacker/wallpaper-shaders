/**********************************
 *
 * Googly Eyes: Googly-eyed clock with a wave that shows battery level
 *
 **********************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec3 daytime;
uniform float battery;
uniform vec2 offset;
uniform int nightMode;
uniform float ftime;

const float TAU = 2.0 * 3.14159;
const float EYE_RADIUS = 0.1;
const float EYE_SEP = 0.125;

float angle(float x, float period) {
	return TAU * x * (1.0/period);
}

bool circle(vec2 uv, vec2 pos, float out_rad, float in_rad) {
	uv -= pos;
	float rad = length(uv);
	return rad <= out_rad && rad >= in_rad;
}

bool iris(vec2 uv, vec2 center, float angle) {
	vec2 disp = EYE_RADIUS * 0.45 * vec2(sin(angle), cos(angle));

	return circle(uv, center + disp, EYE_RADIUS * 0.5, 0.0);
}

bool eyes(vec2 uv, vec2 center, vec2 sep) {
	float r1 = EYE_RADIUS,
			r2 = r1 *1.075;

	bool e1 = circle(uv, center - sep, r2, r1),
			e2 = circle(uv, center + sep, r2, r1);

	float ma = angle(daytime[1], 60.0);
	float ha = angle(daytime[0], 12.0) + ma/13.0;

	bool i1 = iris(uv, center - sep, ha),
		i2 = iris(uv, center + sep, ma);

	return e1 || e2 || i1 || i2;
}

bool under_wave(vec2 uv, float h) {
	float w = 0.05 * sin(angle(2.0*uv.x, 1.0) - angle(ftime, 1.0));
	return abs((uv.y - h) - w) < 0.05;
}

void main(void) {
	vec2 uv = gl_FragCoord.xy / min(resolution.x, resolution.y);

	vec2 center = vec2(0.5, 1.0);
	vec2 sep = vec2(EYE_SEP, 0.0);

	center.x -= (offset - 0.5) * 0.5;

	bool e = eyes(uv, center, sep);
	bool w = under_wave(uv, 2.0 * battery);

	bool night = nightMode == 1;

	vec4 c = vec4(0.0);
	c.a = 1.0;

	if (!night)
		c.rgb =  vec3(1.0);

	bool fg = (!e && w) || (e && !w);

	if (fg) {
		if (night)
			c.rgb = vec3(0.3, 0.9, uv.y * 0.7);
		else
			c.rgb = vec3(0.5, uv.y * 0.5, 0.9);
	}

	gl_FragColor = mix(c, vec4(0.0), 0.0);
}
