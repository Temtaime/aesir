use PASS_DATA
use PASS_DRAW_ID
use TRANS_COLOR

SHADOWS_ENABLED
	use MODEL_MAT
LIGHTING_FULL
	use MODEL_MAT

LIGHTING_ENABLED
	use PASS_NORMALS
SHADOWS_USE_NORMALS
	use PASS_NORMALS

import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;

	PASS_NORMALS
		layout(location = 1) in vec3 pe_normal;

	layout(location = 2) in vec2 pe_tex_coord;

	void main()
	{
		DO_DATA_PASS
		vec4 v = vec4(pe_vertex, 1.);

		MODEL_MAT
			vec4 pos = TRANS.model * v;

		PASS_NORMALS
			vert.norm = vec3(TRANS.normal * vec4(pe_normal, 0.));

		SHADOWS_ENABLED
			vert.shadowPos = pe_shadow_matrix * pos;

		LIGHTING_FULL
			vert.pos = pos;

		vert.texCoord = pe_tex_coord;

		gl_Position = TRANS.mvp * v;
	}

fragment:
	SHADOWS_ENABLED
		import shadows
	LIGHTING_ENABLED
		import lighting

	out vec4 pe_frag_color;

	void main()
	{
		vec4 c = SAMPLE_TEX;

		if(c.a < .05)
		{
			discard;
		}

		c *= TRANS.color;

		LIGHTING_ENABLED
			calcLights(c.rgb);

		SHADOWS_ENABLED
			calcShadows(vert.shadowPos, 0.0, c.rgb);

		USE_FOG
			c.rgb = mix(c.rgb, FOG_COLOR, smoothstep(FOG_NEAR, FOG_FAR, gl_FragCoord.z / gl_FragCoord.w));

		pe_frag_color = c;
	}
