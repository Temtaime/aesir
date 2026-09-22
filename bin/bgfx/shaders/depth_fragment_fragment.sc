$input v_color0
$input v_texcoord0
#include "bgfx_shader.sh"
SAMPLER2D(s_texMain, 0);
void main()
{
	if (texture2D(s_texMain, v_texcoord0).a < 0.05)
		discard;
}
