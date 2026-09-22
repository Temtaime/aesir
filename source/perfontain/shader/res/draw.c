vertex:
	$input a_position, a_normal, a_texcoord0
	$output v_texcoord0
	SHADOWS_ENABLED
		$output v_shadowPos

	#include "bgfx_shader.sh"

	SHADOWS_ENABLED
		uniform mat4 u_shadowMatrix;
		uniform mat4 u_shadowModel;

	void main()
	{
		v_texcoord0 = a_texcoord0;
		SHADOWS_ENABLED
			v_shadowPos = mul(u_shadowMatrix, mul(u_shadowModel, vec4(a_position, 1.0)));
		gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
	}

fragment:
	$input v_texcoord0
	SHADOWS_ENABLED
		$input v_shadowPos

	#include "bgfx_shader.sh"

	SAMPLER2D(s_texMain, 0);
	SHADOWS_ENABLED
		SAMPLER2D(s_shadowMap, 1);
	uniform vec4 u_color;

	void main()
	{
		vec4 color = texture2D(s_texMain, v_texcoord0);

		if (color.a < 0.05)
			discard;

		SHADOWS_ENABLED
			vec3 shadowCoord = v_shadowPos.xyz / v_shadowPos.w;
			SHADOWS_FLIP_Y
				shadowCoord.y = 1.0 - shadowCoord.y;
			float shadow = step(shadowCoord.z - 0.001, texture2D(s_shadowMap, shadowCoord.xy).x);
			color.rgb *= 0.5 + shadow * 0.5;
		gl_FragColor = color * u_color;
	}
