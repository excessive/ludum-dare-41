#ifdef VERTEX
uniform mat4 u_model, u_view, u_projection;
uniform vec2 u_clips;
uniform float u_curvature;

vec4 position(mat4 mvp, vec4 vertex_position) {
	float f_distance = length((u_view * u_model * vertex_position).xyz);

	float scaled = (f_distance - u_clips.x) / (u_clips.y - u_clips.x);

	vertex_position = u_model * vertex_position;
	vertex_position.z -= pow(scaled, 3.0) * u_curvature;

	vec4 pos4 = u_projection * u_view * vertex_position;
	// slight depth offset to help show over surfaces
	pos4.z -= 0.0025;
	return pos4;
}
#endif

#ifdef PIXEL
uniform vec3 u_white_point;
uniform float u_exposure;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	return vec4((color.rgb / exp2(u_exposure)) * u_white_point, color.a);
}
#endif
