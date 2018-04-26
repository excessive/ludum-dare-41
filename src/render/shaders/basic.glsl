varying vec3 f_normal;
varying float f_distance;

#ifdef VERTEX
attribute vec3 VertexNormal;
attribute vec4 VertexWeight;
attribute vec4 VertexBone; // used as ints!

uniform mat4 u_model, u_view, u_projection;
uniform mat4 u_normal_mtx;

uniform int u_rigged;
uniform mat4 u_pose[90];

uniform vec2 u_clips;
uniform float u_curvature;

mat4 getDeformMatrix() {
	// *255 because byte data is normalized against our will.
	return
		u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
		u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
		u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
		u_pose[int(VertexBone.w*255.0)] * VertexWeight.w
	;
}

vec4 position(mat4 mvp, vec4 vertex) {
	mat4 transform = u_model;
	if (u_rigged == 1) {
		transform *= getDeformMatrix();
		f_normal = mat3(transform) * VertexNormal;
	}
	else {
		f_normal = mat3(u_normal_mtx) * VertexNormal;
	}
	float dist = length((u_view * u_model * vertex).xyz);
	float scaled = (dist - u_clips.x) / (u_clips.y - u_clips.x);

	f_distance = dist / u_clips.y;

	vertex.z -= pow(scaled, 3.0) * u_curvature;

	return u_projection * u_view * transform * vertex;
}
#endif

#ifdef PIXEL
uniform vec3 u_light_direction;
uniform float u_light_intensity;
uniform vec2 u_clips;
uniform vec3 u_fog_color;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc) {
	vec3 light = normalize(u_light_direction);
	vec3 normal = normalize(f_normal);
	float shade = dot(normal, light);
	shade = max(shade, 0.3);
	shade *= u_light_intensity;

	color += 0.025;

	// ambient
	vec3 top = vec3(0.2, 0.7, 1.0) * 3.0;
	vec3 bottom = vec3(0.30, 0.25, 0.35) * 2.0;
	vec3 ambient = mix(top, bottom, dot(normal, vec3(0.0, 0.0, -1.0)) * 0.5 + 0.5);
	ambient *= color.rgb;
	ambient *= clamp(u_light_intensity, 0.25, 1.0);

	// combine diffuse with light info
	vec3 diffuse = Texel(tex, uv).rgb * color.rgb * vec3(shade * 10.0);
	diffuse += ambient;

	// mix ambient beyond the terminator
	vec3 out_color = mix(ambient.rgb, diffuse.rgb, clamp(dot(light, normal) + 0.2, 0.0, 1.0));

	// fog
	float scaled = pow(f_distance, 1.6);

	vec3 final = mix(out_color.rgb, u_fog_color, scaled);
	final *= final;

	return vec4(final, 1.0);
}
#endif
