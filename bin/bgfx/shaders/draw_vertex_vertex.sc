$input a_position, a_normal, a_texcoord0
$output v_texcoord0
$output v_shadowPos
#include "bgfx_shader.sh"
uniform mat4 u_shadowMatrix;
uniform mat4 u_shadowModel;
void main()
{
	v_texcoord0 = a_texcoord0;
	v_shadowPos = mul(u_shadowMatrix, mul(u_shadowModel, vec4(a_position, 1.0)));
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
