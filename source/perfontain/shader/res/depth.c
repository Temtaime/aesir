use PASS_DATA

import header
import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;

	TEXTURED
		layout(location = 2) in vec2 pe_tex_coord;

	void main()
	{
		TEXTURED
			DO_DATA_PASS
			texCoord = pe_tex_coord;

		gl_Position = TRANS.mvp * vec4(pe_vertex, 1.0);
	}

fragment:
	void main()
	{
		TEXTURED
			if(SAMPLE_TEX.a < 0.05) discard;
	}
