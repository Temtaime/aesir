$input a_position, a_normal, a_texcoord0
$output v_texcoord0
$output v_shadowPos
$output v_normal, v_worldPos
#include "bgfx_shader.sh"
uniform mat4 u_shadowMatrix;
uniform mat4 u_shadowModel;
uniform mat4 u_lightingModel;
void main()
{
	v_texcoord0 = a_texcoord0;
	v_shadowPos = mul(u_shadowMatrix, mul(u_shadowModel, vec4(a_position, 1.0)));
	v_normal = mul(u_lightingModel, vec4(a_normal, 0.0)).xyz;
	v_worldPos = mul(u_lightingModel, vec4(a_position, 1.0)).xyz;
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
