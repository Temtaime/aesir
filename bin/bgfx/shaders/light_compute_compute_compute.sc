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
	vec3 clip = vec3(uv * 2.0 - 1.0, depth);
	vec4 p = mul(u_projViewInversed, vec4(clip, 1.0));
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
	uint pixel = uint(depth * 255.0);
	imageStore(u_lightsIndices, coord, uvec4(pixel, 0u, 0u, 0u));
}
