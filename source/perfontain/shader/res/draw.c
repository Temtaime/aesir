vertex:
	$input a_position, a_normal, a_texcoord0
	$output v_texcoord0

	#include "bgfx_shader.sh"

	void main()
	{
		v_texcoord0 = a_texcoord0;
		gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
	}

fragment:
	$input v_texcoord0

	#include "bgfx_shader.sh"

	SAMPLER2D(s_texMain, 0);

	void main()
	{
		gl_FragColor = texture2D(s_texMain, v_texcoord0);
	}
