import header

layout(local_size_x = 32, local_size_y = 32) in;
layout(r32ui, binding = 0) uniform writeonly highp uimage2D output_tex;

uniform mat4 proj_view_inversed;
__TEX_ID__ uniform sampler2D pe_tex_lights_depth;

struct LightSource
{
	vec4 pos;
	vec3 color;
};

__SSBO_ID__ buffer pe_lights
{
	LightSource lights[];
};

compute:
	vec3 pixel_pos(vec3 clip)
	{
		vec4 p = proj_view_inversed * vec4(clip * 2.0 - 1.0, 1.0);
		return p.xyz / p.w;
	}

	uint makeColor(vec2 uv)
	{
		const uint end = 1u << 24;

		uint pixel = 0u;
		float depth = texture(pe_tex_lights_depth, uv).r;

		if(depth < 0.99)
		{
			vec3 pos = pixel_pos(vec3(uv, depth));

			for(int i = 0; i < lights.length(); i++)
			{
				vec4 l = lights[i].pos;

				if(distance(l.xyz, pos) < l.w)
				{
					pixel = (pixel << 8) | uint(i + 1);

					if(pixel >= end)
					{
						return pixel;
					}
				}
			}
		}

		return pixel;
	}

	void main()
	{
		ivec2 coord = ivec2(gl_GlobalInvocationID.xy);

		if(coord.x >= VIEWPORT_SIZE.x || coord.y >= VIEWPORT_SIZE.y)
			return;

		vec2 uv = vec2(coord) / vec2(VIEWPORT_SIZE);
		uint pixel = makeColor(uv);

		imageStore(output_tex, coord, uvec4(pixel));
	}
