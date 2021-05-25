PASS_DRAW_ID
	use DECL_TRANS
VERTEX_SHADER
	use DECL_TRANS

DECL_TRANS
	struct TransformInfo
	{
		mat4 mvp;

		MODEL_MAT
			mat4 model;
		PASS_NORMALS
			mat4 normal;
		TRANS_COLOR
			vec4 color;
		TRANS_GUI
			ivec4 scissor;
	};

	__SSBO_ID__ buffer pe_transforms
	{
		SHADOWS_ENABLED
			mat4 pe_shadow_matrix;
		TransformInfo transforms[];
	};

PASS_DATA
	PASS_NORMALS
		vsfs vec3 norm;
	SHADOWS_ENABLED
		vsfs vec4 shadowPos;
	LIGHTING_FULL
		vsfs vec4 pos;
	TRANS_GUI
		vsfs vec4 color;

	vsfs vec2 texCoord;

	PASS_DRAW_ID
		vsfs flat int draw_idx;

	TRANS = transforms[DRAW_ID]

VERTEX_SHADER
	uniform int pe_base_draw_id;
	DRAW_ID = (gl_DrawID + pe_base_draw_id)

	PASS_DRAW_ID
		DO_DATA_PASS += draw_idx = DRAW_ID;

FRAGMENT_SHADER
	PASS_DATA
		__TEX_ID__ uniform sampler2D pe_tex_main;

	DRAW_ID = draw_idx
	SAMPLE_TEX = texture(pe_tex_main, texCoord)
