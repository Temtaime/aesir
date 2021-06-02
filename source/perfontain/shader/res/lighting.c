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

	__TEX_ID__ uniform highp usampler2D pe_tex_lights;

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

		vec2 uv = gl_FragCoord.xy / vec2(VIEWPORT_SIZE);
		uint value = texture(pe_tex_lights, uv).r;

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
