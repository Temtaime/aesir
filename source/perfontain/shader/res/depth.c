TEXTURED_SHADOWS
	use PASS_DATA
import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;

	TEXTURED_SHADOWS
		layout(location = 2) in vec2 pe_tex_coord;

	void main()
	{
		TEXTURED_SHADOWS
			DO_DATA_PASS
			vert.texCoord = pe_tex_coord;

		gl_Position = TRANS.mvp * vec4(pe_vertex, 1.);
	}

fragment:
	void main()
	{
		TEXTURED_SHADOWS
			if(SAMPLE_TEX.a < .05) discard;
	}
