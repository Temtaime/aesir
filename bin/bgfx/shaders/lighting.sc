struct LightSource

{
	vec4 pos;
	vec3 color;
};

	void calcLight(vec3 nn, vec3 P, inout vec3 res, uint idx)
	{
		LightSource p;
		p.pos = u_lights[idx * 2u];
		p.color = u_lights[idx * 2u + 1u].xyz;

		vec3 q = P - p.pos.xyz;
		float d = length(q);
		float t = smoothstep(0.0, p.pos.w, d);

		res += clamp(p.color * max(1.0 / (t * t) - 1.0, 0.0) * dot(nn, normalize(q)), 0.0, 1.5);
	}

void calcLights(inout vec3 c, vec3 nn, vec3 P, ivec2 coord)
{
	vec3 res = LIGHT_AMBIENT + LIGHT_DIFFUSE * max(dot(nn, LIGHT_DIR), 0.0);

	uint value = texelFetch(s_lightsIndices, coord, 0).x;
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
