module perfontain.submesh;

import
		std.stdio,
		std.array,
		std.range,
		std.typecons,
		std.container,
		std.algorithm,

		perfontain,
		perfontain.misc.rc,
		perfontain.vbo,
		perfontain.vao,
		perfontain.misc,
		perfontain.mesh,
		perfontain.nodes,
		perfontain.config,
		perfontain.shader,
		perfontain.opengl,
		perfontain.math,
		perfontain.math.bbox,
		perfontain.math.matrix,

		tt.error;


struct SubMeshData
{
	@(`uint`) uint[] indices;
	@(`uint`) ubyte[] vertices;

	const
	{
		uint trianglesCount()
		{
			return cast(uint)indices.length / 3;
		}

		auto asVertexes(ubyte N = 8)()
		{
			return vertices.as!(Vector!(float, N));
		}

		auto asTriangles(uint start = 0, uint end = uint.max)
		{
			return indexed(asVertexes, indices[start..min(end, $)]);//.chunks(3);
		}
	}

	void clear()
	{
		auto vs = asVertexes;

		for(uint i; i < indices.length; )
		{
			auto	a = &vs[indices[i]],
					b = &vs[indices[i + 1]],
					c = &vs[indices[i + 2]];

			if(valueEqual(calcNormal(a.p, b.p, c.p).length, 0)) // TODO: FIX ???
			{
				indices.removeStable(i, i + 1, i + 2);
				//triangleArea(a.p, b.p, c.p).writeln;
			}
			else
			{
				i += 3;
			}
		}
	}

	void makeNormals(uint start = 0, uint end = uint.max, bool ns = false)
	{
		auto tris = asTriangles(start, end);

		foreach(ref t; tris.chunks(3))
		{
			auto n = calcNormal(t[0].p, t[1].p, t[2].p).normalize;

			t[0].n = t[1].n = t[2].n = ns ? -n : n;
		}

		Vector3 *[][int[3]] aa;

		foreach(ref v; tris)
		{
			aa[v.p.flat.toInts] ~= &v.n();
		}

		loop: foreach(arr; aa)
		{
			foreach(u, v; cartesianProduct(arr, arr))
			{
				if(u != v)
				{
					auto	a = *u,
							b = *v;

					if(a.angleTo(b) <= NORMAL_SMOOTH_ANGLE * TO_RAD)
					{
						*u = *v = (a + b) / 2;
					}
				}
			}
		}
	}

	void minimize()
	{
		auto vs = asVertexes;

		auto cor = vs
						.map!(a => a.flat.toInts)
						.array;

		auto tree = cor
						.enumerate
						.redBlackTree!((a, b) => a.value < b.value)
						.array;

		auto ra = tree
						.map!(a => a.value)
						.array
						.assumeSorted;

		vertices = tree
						.map!(a => vs[a.index])
						.array
						.toByte;

		foreach(ref v; indices)
		{
			v = cast(uint)ra.lowerBound(cor[v]).length;
		}
	}
}

struct SubMeshInfo
{
	Image tex;
	SubMeshData data;
}
