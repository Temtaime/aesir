#define VIEWPORT_SIZE ivec2(3740, 2070)
#if BGFX_SHADER_TYPE_VERTEX

$input a_position, a_color0
$output v_texcoord0, v_color0

#include "bgfx_shader.sh"

void main()
{
	v_texcoord0 = a_position.zw;
	v_color0 = a_color0;
	gl_Position = mul(u_modelViewProj, vec4(a_position.xy, 0.0, 1.0));
}

#else

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

#endif

