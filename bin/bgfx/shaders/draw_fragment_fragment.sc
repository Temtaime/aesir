$input v_texcoord0
$input v_shadowPos
#include "bgfx_shader.sh"
SAMPLER2D(s_texMain, 0);
SAMPLER2D(s_shadowMap, 1);
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
	gl_FragColor = color * u_color;
}
