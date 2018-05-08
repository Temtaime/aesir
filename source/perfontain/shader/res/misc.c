PASS_DATA
	vsfs VertexData
	{
		PASS_NORMALS
			vec3 norm;

		SHADOWS_ENABLED
			vec4 shadowPos;

		LIGHTING_FULL
			vec4 pos;

		BINDLESS_TEXTURE
			flat uvec2 tex;
		vec2 texCoord;

		PASS_DRAW_ID
			SHADER_DRAW_PARAMETERS
				flat int idx;
	} vert;

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

		LIGHTING_FULL
			int lightStart, lightEnd;
	};

	layout(std430) readonly buffer pe_transforms
	{
		SHADOWS_ENABLED
			mat4 pe_shadow_matrix;
		TransformInfo transforms[];
	};

	TRANS = transforms[DRAW_ID]

VERTEX_SHADER
	BINDLESS_TEXTURE
		layout(std430) readonly buffer pe_submeshes
		{
			uvec4 submeshes[];
		};

	SHADER_DRAW_PARAMETERS
		BINDLESS_TEXTURE
			PASS_DATA
				DRAW_ID = int(sm.z)
			else
				DRAW_ID = int(submeshes[gl_DrawIDARB].z)
		else
			DRAW_ID = gl_DrawIDARB
	else
		DRAW_ID = pe_object_id

	out gl_PerVertex { vec4 gl_Position; };

	BINDLESS_TEXTURE
		DO_DATA_PASS = uvec4 sm = submeshes[gl_DrawIDARB]; vert.tex = sm.xy;

	PASS_DRAW_ID
		SHADER_DRAW_PARAMETERS
			DO_DATA_PASS += vert.idx = DRAW_ID;

	!SHADER_DRAW_PARAMETERS
		uniform int pe_object_id;

FRAGMENT_SHADER
	PASS_DATA
		!BINDLESS_TEXTURE
			uniform sampler2D pe_texture;

	SHADER_DRAW_PARAMETERS
		DRAW_ID = vert.idx
	else
		DRAW_ID = pe_object_id

	BINDLESS_TEXTURE
		SAMPLE_TEX = texture(sampler2D(vert.tex), vert.texCoord)
	else
		SAMPLE_TEX = texture(pe_texture, vert.texCoord)

	PASS_DRAW_ID
		!SHADER_DRAW_PARAMETERS
			uniform int pe_object_id;
