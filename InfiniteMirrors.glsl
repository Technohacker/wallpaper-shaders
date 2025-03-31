/************************************
 *
 * Infinite Mirrors: Cross pattern that spreads from last touched point
 *
 ************************************/

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec2 touch;
uniform float time;
uniform sampler2D backbuffer;

void main(void) {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec4 color = vec4(0.4, 0.6, 0.6, 0.0);
	vec4 prevColor = 1.4 * texture2D(backbuffer, (uv - vec2(0.05)) * vec2(1.1));

	bool fg = distance(gl_FragCoord.xy, touch) < 100.0;

	fg = fg || abs(gl_FragCoord.x - touch.x) < 50.0; // * abs(sin(1.0 * time));
	fg = fg || abs(gl_FragCoord.y - touch.y) < 50.0; // * abs(cos(1.0 * time));
	if (fg) {
		gl_FragColor = color;
	} else {
		gl_FragColor = color * prevColor;
	}
}
