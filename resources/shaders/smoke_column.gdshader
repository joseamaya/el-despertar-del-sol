shader_type spatial;
// Smoke column for the horizon (F3 task 6): a vertical tube that widens as it rises,
// unshaded and transparent. Dense near the ground, it thins and lightens upwards and
// fades at its silhouette; the noise drifts up. Cheap on the Mobile renderer: no
// particles, no lighting, no shadows.
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec4 smoke_color : source_color = vec4(0.36, 0.33, 0.32, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.6;
uniform float column_height = 200.0;
uniform float rise_speed = 0.03;
uniform float seed = 0.0;

varying float height01;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	// The mesh is centred on its origin: 0 at the base, 1 at the top.
	height01 = clamp(VERTEX.y / column_height + 0.5, 0.0, 1.0);
}

void fragment() {
	vec2 uv = vec2(UV.x, height01) + vec2(seed, -TIME * rise_speed);
	float n = noise(uv * vec2(6.0, 4.0)) * 0.6 + noise(uv * vec2(15.0, 9.0)) * 0.4;
	float edge = smoothstep(0.0, 0.6, abs(dot(NORMAL, VIEW)));
	float rise = smoothstep(0.0, 0.06, height01) * pow(1.0 - height01, 1.3);
	ALBEDO = mix(smoke_color.rgb, vec3(0.78, 0.74, 0.72), height01 * 0.6) * (0.9 + 0.2 * n);
	ALPHA = opacity * edge * rise * smoothstep(0.2, 0.7, n + 0.25);
}
