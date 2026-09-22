$input v_texcoord0, v_color0
#include "bgfx_shader.sh"
SAMPLER2D(s_texMain, 0);
void main()
{
	vec4 c = texture2D(s_texMain, v_texcoord0) * v_color0;
	if (c.a < 0.05)
		discard;
	gl_FragColor = c;
}
