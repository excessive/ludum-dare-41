#pragma language glsl3

uniform float u_exposure;
uniform vec3 u_white_point;
uniform float u_vignette;

vec3 Tonemap_ACES(vec3 x) {
	float a = 2.51;
	float b = 0.03;
	float c = 2.43;
	float d = 0.59;
	float e = 0.14;
	return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

float vignette(vec2 uv) {
	vec2  center = vec2(0.5, 0.5);
	float distance_from_center = distance(uv, center);
	float power = 1.7;
	float offset = 2.75;
	return 1.0 - pow((distance_from_center*2.0) / (center.x * offset), power);
}

// Sigmoid function, sign(v)*pow(pow(abs(v), -2) + pow(s, -2), 1.0/-2)
#define soft_lim(v,s)  ( (v*s)*(1.0/sqrt(s*s + v*v)) )

// Weighted power mean, p = 0.5
#define wpmean(a,b,w)  (pow(abs(w)*sqrt(abs(a)) + abs(1.0-w)*sqrt(abs(b)), vec3(2.0)))

// Max/Min RGB components
#define max3(RGB) ( max((RGB).r, max((RGB).g, (RGB).b)) )
#define min3(RGB) ( min((RGB).r, min((RGB).g, (RGB).b)) )

// Mean of Rec. 709 & 601 luma coefficients
// const vec3 luma = vec3(0.2558, 0.6511, 0.0931);
const vec3 luma = vec3(0.212656, 0.715158, 0.072186);

vec3 vibrance(vec3 c0, float saturation, float lim_luma) {
	float luma = sqrt(dot(clamp(c0*abs(c0), 0.0, 1.0), luma));
	c0 = clamp(c0, 0.0, 1.0);

	// Calc colour saturation change
	vec3 diff_luma = c0 - luma;
	vec3 c_diff = diff_luma*(saturation + 1.0) - diff_luma;

	// 120% of c_diff clamped to max visible range + overshoot
	vec3 rlc_diff = clamp((c_diff*1.2) + c0, -0.0001, 1.0001) - c0;

	// Calc max saturation-increase without altering RGB ratios
	float poslim = (1.0002 - luma)/(abs(max3(diff_luma)) + 0.0001);
	float neglim = (luma + 0.0002)/(abs(min3(diff_luma)) + 0.0001);

	vec3 diffmax = diff_luma*min(min(poslim, neglim), 32.0) - diff_luma;

	// Soft limit diff
	c_diff = soft_lim( c_diff, max(wpmean(diffmax, rlc_diff, lim_luma), 1e-6) );

	return clamp(c0 + c_diff, 0.0, 1.0);
}

vec4 effect(vec4 vcol, Image texture, vec2 texture_coords, vec2 sc) {
	vec3 texColor = textureLod(texture, vec2(texture_coords.x, 1.0-texture_coords.y), 0.0).rgb;
	texColor = sqrt(texColor);
	// texColor = pow(texColor, vec3(1.0/2.0));
	// texColor *= texColor;

	texColor *= exp2(u_exposure);
	texColor *= min(1.0, vignette(texture_coords) + (1.0-u_vignette));

	vec3 white = Tonemap_ACES(vec3(1000.0));
	vec3 color = Tonemap_ACES(texColor/u_white_point)*white;

	// bump up final saturation...
	color = vibrance(color, 0.3, 0.65);

	return vec4(color, 1.0);
}
