module perfontain.render.types;

import
		std.algorithm;


enum
{
	RENDER_GUI,
	RENDER_SCENE,
}

static immutable ubyte[][] renderLoc =
[
	[ 4 ], // vec4
	[ 3, 3, 2 ], // vec3, vec3, vec2
];

auto vertexSize(ubyte type)
{
	return cast(ubyte)(renderLoc[type].sum * 4);
}
