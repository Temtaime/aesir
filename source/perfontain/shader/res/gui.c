use PASS_DATA
use PASS_DRAW_ID

use TRANS_COLOR

import misc

vertex:
	layout(location = 0) in vec4 pe_vertex;

	void main()
	{
		DO_DATA_PASS

		vert.texCoord = pe_vertex.zw;
		gl_Position = TRANS.mvp * vec4(pe_vertex.xy, 0., 1.);
	}

fragment:
	out vec4 pe_frag_color;

	void main()
	{
		vec4 c = SAMPLE_TEX;

		if(c.a < .05)
		{
			discard;
		}

		pe_frag_color = c * TRANS.color;
	}
