#if BGFX_SHADER_TYPE_VERTEX

$input a_position, a_texcoord0
$output v_color0

#ifdef TEXTURED
$output v_texcoord0
#endif

#include "bgfx_shader.sh"

void main()
{
#ifdef TEXTURED
	v_texcoord0 = a_texcoord0;
#endif
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}

#else

$input v_color0

#ifdef TEXTURED
$input v_texcoord0
#endif

#include "bgfx_shader.sh"

#ifdef TEXTURED
SAMPLER2D(s_texMain, 0);
#endif

void main()
{
#ifdef TEXTURED
	if (texture2D(s_texMain, v_texcoord0).a < 0.05)
		discard;
#endif
#ifdef LIGHTS_DEPTH
	gl_FragColor = vec4(vec3_splat(gl_FragCoord.z), 1.0);
#endif
}

#endif
