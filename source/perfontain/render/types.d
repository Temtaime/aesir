module perfontain.render.types;
import std;


enum
{
	RENDER_GUI,
	RENDER_SCENE,
}

static immutable renderLoc =
[
	[ 4, 4 ], // vec4, vec4
	[ 3, 3, 2 ], // vec3, vec3, vec2
];

auto vertexSize(ubyte type)
{
	return cast(ubyte)renderLoc[type].map!(a => a * 4).sum;
}
