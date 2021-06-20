__TEX_ID__ uniform sampler2D pe_tex_shadows_depth;

const float bias = 0.001, shadowFactor = 0.5;

float lkup(vec3 coord)
{
	SHADOWS_USE_NORMALS
		float t = tan(acos(max(dot(normalize(vert.norm), LIGHT_DIR), 0.0)));
		t = max(bias * t, bias * 3.0);

		BIAS = t
	else
		BIAS = bias

	return step(coord.z - BIAS, texture(pe_tex_shadows_depth, coord.xy).x);
}

void calcShadows(vec4 pos, float value, inout vec3 color)
{
	color = mix(color, color * lkup(pos.xyz / pos.w), shadowFactor - min(value / 20.0, shadowFactor));
}
