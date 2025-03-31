/**********************************
 *
 * Gradual Brightness Reveal: Only shows pixels within a periodic, time-varying luminosity range
 *
 **********************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

#define FTIME_PERIOD 5.0

uniform vec2 resolution;
uniform vec2 offset;
uniform float ftime;

uniform sampler2D background_test;///min:n;mag:l;s:c;t:c;

#define BG background_test
#define EPS 0.25

float luma(vec4 color) {
  return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

float remapped_ftime(float lo, float hi) {
	return lo + (ftime + 1.0) * (hi - lo / 2.0);
}

void main(void) {
	vec2 uv = gl_FragCoord.xy / resolution.x;

	float threshold = remapped_ftime(-EPS, 1.0 + EPS);

	vec4 color = texture2D(BG, uv - vec2(-0.5 * (offset.x - 0.5), 0.5));
	float brightness = luma(color);
	float within_range = (
		smoothstep(threshold - 1.5 * EPS, threshold - EPS, brightness)
		//+ 1.0
		- smoothstep(threshold + EPS, threshold + 1.5 * EPS, brightness)
	);

	gl_FragColor = mix(vec4(0.0), color, within_range);
}
