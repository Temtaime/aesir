vertex:
	$input a_position
	$output v_color0

	#include "bgfx_shader.sh"

	void main()
	{
		gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
	}

fragment:
	$input v_color0

	#include "bgfx_shader.sh"

	void main()
	{
	}
