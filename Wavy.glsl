/*************************************
 *
 * Wavy: Gyroscope-sensitive moving background with behaviour based on battery level
 *
 *************************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec3 gravity;
uniform int frame;
uniform float battery;
uniform int powerConnected;
uniform sampler2D backbuffer;///min:n;mag:n;s:c;t:r;

#define LOW (vec4(255, 0, 0, 255) / 256.0)
#define HIGH (vec4(0, 255, 0, 255) / 256.0)

void main(void) {
	vec2 pos = gl_FragCoord.xy;
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 center = resolution / 2.0;

	bool border = false;
	border = border || (
		abs(pos.x - 50.0) < 50.0
		&& mod(pos.y - float(2 * powerConnected - 1) * float(frame), 100.0) < 50.0
	);
	if (border) {
		gl_FragColor = mix(LOW, HIGH, battery);
	} else {
		vec2 back_pos = uv - vec2(0.1, -0.05) - (gravity.xy / 100.0) * vec2(+1, -1);
		gl_FragColor = 0.90 * texture2D(backbuffer, 0.9 * back_pos);
	}
}
