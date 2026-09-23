$input

#include "bgfx_shader.sh"
#include "bgfx_compute.sh"

SAMPLER2D(s_lightsDepth, 0);
UIMAGE2D_WO(u_lightsIndices, r32ui, 1);

uniform mat4 u_projViewInversed;
uniform vec4 u_lights[256];
uniform vec4 u_lightsInfo;

vec3 pixelPos(vec2 uv, float depth)
{
	vec3 ndc = vec3(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, depth);
	vec4 p = mul(u_projViewInversed, vec4(ndc, 1.0));
	return p.xyz / p.w;
}

NUM_THREADS(32, 32, 1)
void main()
{
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = imageSize(u_lightsIndices);

	if (any(greaterThanEqual(coord, size)))
		return;

	vec2 uv = vec2(coord) / vec2(size);
	float depth = texture2DLod(s_lightsDepth, uv, 0.0).x;
	const uint end = 1u << 24;
	uint pixel = 0u;

	if (depth < 1.0)
	{
		vec3 pos = pixelPos(uv, depth);

		for (int i = 0; i < int(u_lightsInfo.x); i++)
		{
			vec4 light = u_lights[i * 2];

			if (distance(light.xyz, pos) < light.w)
			{
				pixel = (pixel << 8) | uint(i + 1);
				if (pixel >= end)
					break;
			}
		}
	}

	imageStore(u_lightsIndices, coord, uvec4(pixel, 0u, 0u, 0u));
}
