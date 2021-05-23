use PASS_DATA

import header
import misc

vertex:
	layout(location = 0) in vec3 pe_vertex;

	void main()
	{
		gl_Position = TRANS.mvp * vec4(pe_vertex, 1.0);
	}

fragment:
	void main()
	{
	}
