$input v_texcoord0
$input v_shadowPos
$input v_normal, v_worldPos
#include "bgfx_shader.sh"
SAMPLER2D(s_texMain, 0);
SAMPLER2D(s_shadowMap, 1);
USAMPLER2D(s_lightsIndices, 2);
uniform vec4 u_lights[256];
uniform vec4 u_lightsInfo;
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
	vec3 lightResult = vec3_splat(1.0);
	uint packed = texelFetch(s_lightsIndices, ivec2(gl_FragCoord.xy), 0).x;
	for (int i = 0; i < 4; i++)
	{
		uint index = packed & 0xFFu;
		if (index == 0u)
			break;
		packed >>= 8;
		vec4 light = u_lights[(index - 1u) * 2u];
		vec3 delta = light.xyz - v_worldPos;
		float distanceToLight = length(delta);
		float attenuation = max(1.0 - distanceToLight / light.w, 0.0);
		lightResult += u_lights[(index - 1u) * 2u + 1u].xyz * attenuation * max(dot(normalize(-v_normal), normalize(delta)), 0.0);
	}
	color.rgb *= lightResult;
	gl_FragColor = color * u_color;
}
