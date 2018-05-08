LIGHTING_FULL
	struct LightSource
	{
		vec4 pos;
		vec3 color;
	};

	layout(std430) readonly buffer pe_lights
	{
		LightSource lights[];
	};

	layout(std430) readonly buffer pe_lights_raw
	{
		int indices[];
	};

void calcLights(inout vec3 c)
{
	vec3 norm = normalize(vert.norm);
	vec3 res = LIGHT_AMBIENT + LIGHT_DIFFUSE * max(dot(norm, LIGHT_DIR), 0.);

	LIGHTING_FULL
		vec3 P = vec3(vert.pos.xyz / vert.pos.w);

		for(int i = TRANS.lightStart, e = TRANS.lightEnd; i < e; i++)
		{
			LightSource p = lights[indices[i]];

			vec3 q = P - p.pos.xyz;

			float d = length(q);
			float t = smoothstep(0., p.pos.w, d);

			res += clamp(p.color * max(1. / (t * t) - 1., 0.) * dot(norm, normalize(q)), 0., 1.5);
		}

	c *= res;
}
