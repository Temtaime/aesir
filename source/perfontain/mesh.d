module perfontain.mesh;

import std.stdio, std.array, std.range, std.algorithm, perfontain, perfontain.vbo, perfontain.opengl,
	perfontain.config, perfontain.shader, perfontain.math.bbox, perfontain.math.matrix;

struct MeshInfo
{
	@(`ubyte`) SubMeshInfo[] subs;
	bool ns;
}

void swapTrisOrder(ref MeshInfo m)
{
	foreach (ref s; m.subs = m.subs.dup)
		with (s.data)
		{
			indices = indices.chunks(3).map!(a => a.retro).join;
		}
}

auto calcBBox(in MeshInfo m)
{
	return m.subs
		.map!(a => BBox(a.data.asVertexes))
		.fold!((a, b) => a + b); // TODO: WILL THROW ON EMPTY INPUT
}
