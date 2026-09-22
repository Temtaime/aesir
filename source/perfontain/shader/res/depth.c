vertex:
	$input a_position, a_texcoord0
	$output v_color0
	TEXTURED
		$output v_texcoord0

	#include "bgfx_shader.sh"

	void main()
	{
		TEXTURED
			v_texcoord0 = a_texcoord0;
		gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
	}

fragment:
	$input v_color0
	TEXTURED
		$input v_texcoord0

	#include "bgfx_shader.sh"
	TEXTURED
		SAMPLER2D(s_texMain, 0);

	void main()
	{
		TEXTURED
			if (texture2D(s_texMain, v_texcoord0).a < 0.05)
				discard;
	}
