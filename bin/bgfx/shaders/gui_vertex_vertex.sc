$input a_position, a_color0
$output v_texcoord0, v_color0
#include "bgfx_shader.sh"
void main()
{
	v_texcoord0 = a_position.zw;
	v_color0 = a_color0;
	gl_Position = mul(u_modelViewProj, vec4(a_position.xy, 0.0, 1.0));
}
