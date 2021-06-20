import header

use PASS_DATA
use PASS_DRAW_ID
use TRANS_GUI

import misc

vertex:
	layout(location = 0) in vec4 pe_vertex;
	layout(location = 1) in vec4 pe_color;

	void main()
	{
		DO_DATA_PASS

		color = pe_color;
		texCoord = pe_vertex.zw;

		gl_Position = TRANS.mvp * vec4(pe_vertex.xy, 0., 1.);
	}

fragment:
	out vec4 pe_frag_color;

	void main()
	{
		ivec2 coord = ivec2(gl_FragCoord);

		if(coord.x < TRANS.scissor.x || coord.x >= TRANS.scissor.z || coord.y < TRANS.scissor.y || coord.y >= TRANS.scissor.w)
			discard;

		vec4 c = SAMPLE_TEX * color;

		if(c.a < .05)
			discard;

		pe_frag_color = c;
	}
