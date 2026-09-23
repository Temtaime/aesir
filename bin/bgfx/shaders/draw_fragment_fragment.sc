$input v_texcoord0
$input v_shadowPos
$input v_normal, v_worldPos
#include "bgfx_shader.sh"
SAMPLER2D(s_texMain, 0);
SAMPLER2D(s_shadowMap, 1);
USAMPLER2D(s_lightsIndices, 2);
uniform vec4 u_lights[256];
uniform vec4 u_lightsInfo;
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
	vec3 res = vec3(0.245, 0.21, 0.245) + vec3(0.6, 0.4, 0.7) * max(dot(nn, vec3(0.709407, -0.573576, -0.409576)), 0.0);
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
uniform vec4 u_color;
void main()
{
	vec4 color = texture2D(s_texMain, v_texcoord0);
	if (color.a < 0.05)
		discard;
	vec3 shadowCoord = v_shadowPos.xyz / v_shadowPos.w;
	shadowCoord.y = 1.0 - shadowCoord.y;
	float shadow = step(shadowCoord.z - 0.001, texture2D(s_shadowMap, shadowCoord.xy).x);
	color.rgb *= 0.5 + shadow * 0.5;
	calcLights(color.rgb, normalize(v_normal), v_worldPos, ivec2(gl_FragCoord.xy));
	gl_FragColor = color * u_color;
}
