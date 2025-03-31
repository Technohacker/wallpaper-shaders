/**********************************
 *
 * Line Scan: CRT-like line-scan effect with pixel fading
 *
 **********************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

#define FTIME_PERIOD 2.25
uniform vec2 resolution;
uniform float ftime;
uniform sampler2D backbuffer;
uniform sampler2D background2;
uniform int frame;

const float SCAN_SIZE = 20.0;

bool inScan() {
	float ft = (ftime + 1.0) * 0.5;

	/*return abs(
		(gl_FragCoord.y * 10.0) + gl_FragCoord.x
		- 10.0*float(frame)
	) < 4.95;*/

	return abs(
		gl_FragCoord.y - mix(
			0.0, resolution.y,
			ft
		)
	) < SCAN_SIZE;
}

void main(void) {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 uv_s = gl_FragCoord.xy / resolution.y;

	if (inScan()) {
		gl_FragColor = texture2D(background2, uv_s + vec2(0.5, 0.0));
	} else {
		gl_FragColor = texture2D(backbuffer, uv) - vec4(0.0075);
	}
}
