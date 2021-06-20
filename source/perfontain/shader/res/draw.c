use PASS_DATA
use PASS_DRAW_ID
use TRANS_COLOR

LIGHTING_FULL
	use MODEL_MAT
SHADOWS_ENABLED
	use MODEL_MAT

LIGHTING_ENABLED
	use PASS_NORMALS

import header
import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;
	layout(location = 1) in vec3 pe_normal;
	layout(location = 2) in vec2 pe_tex_coord;

	void main()
	{
		vec4 v = vec4(pe_vertex, 1.0);

		MODEL_MAT
			vec4 p = TRANS.model * v;

		LIGHTING_FULL
			pos = p;

		SHADOWS_ENABLED
			shadowPos = pe_shadow_matrix * p;

		LIGHTING_ENABLED
			norm = vec3(TRANS.normal * vec4(pe_normal, 0.0));

		texCoord = pe_tex_coord;
		gl_Position = TRANS.mvp * v;
	}

fragment:
	LIGHTING_ENABLED
		import lighting

	SHADOWS_ENABLED
		import shadows

	out vec4 pe_frag_color;

	void main()
	{
		vec4 u = SAMPLE_TEX;

		if(u.a < 0.05)
			discard;

		u *= TRANS.color;

		LIGHTING_ENABLED
			calcLights(u.rgb);

		SHADOWS_ENABLED
			calcShadows(shadowPos, 0.0, u.rgb);

		USE_FOG
			u.rgb = mix(u.rgb, FOG_COLOR, smoothstep(FOG_NEAR, FOG_FAR, gl_FragCoord.z / gl_FragCoord.w));

		pe_frag_color = u;
	}
