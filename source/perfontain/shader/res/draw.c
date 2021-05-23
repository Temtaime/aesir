use PASS_DATA
use MODEL_MAT
use PASS_NORMALS
use LIGHTING_FULL

import header
import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;
	layout(location = 1) in vec3 pe_normal;
	layout(location = 2) in vec2 pe_tex_coord;

	void main()
	{
		vec4 v = vec4(pe_vertex, 1.0);
		vec4 p = TRANS.model * v;

		texCoord = pe_tex_coord;
		norm = vec3(TRANS.normal * vec4(pe_normal, 0.0));

		pos = p;
		gl_Position = TRANS.mvp * v;
	}

fragment:
	struct LightSource
	{
		vec4 pos;
		vec3 color;
	};

	layout(binding = 1) buffer pe_lights
	{
		LightSource lights[];
	};

	uniform highp usampler2D pe_tex_lights;

	out vec4 pe_frag_color;

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

	void main()
	{
		vec4 u = SAMPLE_TEX;

		if(u.a < .05)
		{
			discard;
		}

		calcLights(u.rgb);

		pe_frag_color = u;
	}
