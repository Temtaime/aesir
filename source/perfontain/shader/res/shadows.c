layout(binding = 1) uniform sampler2D pe_shadow_map;

const float bias = 0.001, shadowFactor = 0.5;

float lkup(vec3 coord)
{
	SHADOWS_USE_NORMALS
		float t = tan(acos(max(dot(normalize(vert.norm), LIGHT_DIR), 0.)));
		t = max(bias * t, bias * 3.);

		BIAS = t
	else
		BIAS = bias

	return step(coord.z - BIAS, texture(pe_shadow_map, coord.xy).x);
}

void calcShadows(vec4 pos, float value, inout vec3 color)
{
	color = mix(color, color * lkup(pos.xyz / pos.w), shadowFactor - min(value / 20, shadowFactor));
}
