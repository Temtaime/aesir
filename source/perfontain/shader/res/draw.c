vertex:
	$input a_position, a_normal, a_texcoord0
	$output v_texcoord0
	SHADOWS_ENABLED
		$output v_shadowPos
	LIGHTS_FULL
		$output v_normal, v_worldPos

	#include "bgfx_shader.sh"

	SHADOWS_ENABLED
		uniform mat4 u_shadowMatrix;
		uniform mat4 u_shadowModel;
	LIGHTS_FULL
		uniform mat4 u_lightingModel;

	void main()
	{
		v_texcoord0 = a_texcoord0;
		SHADOWS_ENABLED
			v_shadowPos = mul(u_shadowMatrix, mul(u_shadowModel, vec4(a_position, 1.0)));
		LIGHTS_FULL
			v_normal = mul(u_lightingModel, vec4(a_normal, 0.0)).xyz;
			v_worldPos = mul(u_lightingModel, vec4(a_position, 1.0)).xyz;
		gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
	}

fragment:
	$input v_texcoord0
	SHADOWS_ENABLED
		$input v_shadowPos
	LIGHTS_FULL
		$input v_normal, v_worldPos

	#include "bgfx_shader.sh"

	SAMPLER2D(s_texMain, 0);
	SHADOWS_ENABLED
		SAMPLER2D(s_shadowMap, 1);
	LIGHTS_FULL
		USAMPLER2D(s_lightsIndices, 2);
		uniform vec4 u_lights[256];
		uniform vec4 u_lightsInfo;
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
		LIGHTS_FULL
			vec3 lightResult = vec3_splat(1.0);
			uint packed = texelFetch(s_lightsIndices, ivec2(gl_FragCoord.xy), 0).x;
			gl_FragColor = vec4(vec3_splat(float(packed) / 255.0), color.a) * u_color;
			return;
			for (int i = 0; i < 4; i++)
			{
				uint index = packed & 0xFFu;
				if (index == 0u)
					break;
				packed >>= 8;
				vec4 light = u_lights[(index - 1u) * 2u];
				vec3 delta = light.xyz - v_worldPos;
				float distanceToLight = length(delta);
				float attenuation = max(1.0 - distanceToLight / light.w, 0.0);
				lightResult += u_lights[(index - 1u) * 2u + 1u].xyz * attenuation;
			}
			color.rgb *= lightResult;
		gl_FragColor = color * u_color;
	}
