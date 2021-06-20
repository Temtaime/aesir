LIGHTING_FULL
	struct LightSource
	{
		vec4 pos;
		vec3 color;
	};

	__SSBO_ID__ buffer pe_lights
	{
		LightSource lights[];
	};

	layout(r32ui, binding = 0) uniform readonly highp uimage2D pe_tex_lights_indices;

	void calcLight(vec3 nn, vec3 P, inout vec3 res, uint idx)
	{
		LightSource p = lights[idx];

		vec3 q = P - p.pos.xyz;
		float d = length(q);
		float t = smoothstep(0.0, p.pos.w, d);

		res += clamp(p.color * max(1.0 / (t * t) - 1.0, 0.0) * dot(nn, normalize(q)), 0.0, 1.5);
	}

void calcLights(inout vec3 c)
{
	vec3 nn = normalize(norm);
	vec3 res = LIGHT_AMBIENT + LIGHT_DIFFUSE * max(dot(nn, LIGHT_DIR), 0.0);

	LIGHTING_FULL
		vec3 P = vec3(pos.xyz / pos.w);

		uint value = imageLoad(pe_tex_lights_indices, ivec2(gl_FragCoord.xy)).r;

		for(int i = 0; i < 4; i++)
		{
			uint k = value & 0xFFu;

			if(k == 0u)
				break;

			value >>= 8;
			calcLight(nn, P, res, k - 1u);
		}

	c *= res;
}
