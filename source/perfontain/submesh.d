module perfontain.submesh;

import
		std.stdio,
		std.array,
		std.range,
		std.typecons,
		std.container,
		std.algorithm,
		std.container.rbtree,

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

		utils.except;


/*enum
{
	NONE,
	NORMAL = 2,
	TEXCOORD = 4,
	COLOR = 8,
}

struct MTriangle
{
	uint[3] v;
	double[4] err = 1;
	int deleted,dirty,attr;
	Vector!(double, 3) n;
	Vector!(double, 3)[3] uvs;
	int material;
}

struct MVertex
{
	Vector!(double, 3) p;
	int tstart,tcount;
	double[10] q = 0;
	int border;
}

extern(C)
{
	bool simplify_mesh(MVertex*	, MTriangle*, ref uint, ref uint);
}*/

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

	void unify()
	{
		/*MVertex[] vs;
		MTriangle[] ts;

		auto r = asVertexes;



		foreach(arr; indices.chunks(3))
		{
			MTriangle t;

			t.v = arr;
			t.attr = TEXCOORD;
			t.material = -1;
			t.uvs = arr.map!(a => Vector!(double, 3)(r[a].t, 0)).array;

			ts ~= t;
		}

		r.each!((ref a) { a.t = Vector2(0); a.n = Vector3(0); });

		minimize;

		foreach(ref v; r)
		{
			vs ~= MVertex(Vector!(double, 3)(v.p));
		}

		foreach(i, arr; indices.chunks(3).enumerate)
		{
			ts[i].v = arr;
		}

		uint	vc = cast(uint)vs.length,
				tc = cast(uint)ts.length;

		auto o = tc;

		if(!simplify_mesh(vs.ptr, ts.ptr, vc, tc,))
		{
			return;
		}

		log(`%s -> %s`, o, tc);

		ts = ts[0..tc];
		vs = vs[0..vc];

		vertices = null;

		foreach(ref t; ts)
		{
			Vertex[3] arr;

			foreach(i, ref v; arr)
			{
				v = Vertex(vs[t.v[i]].p, Vector3.init, t.uvs[i].xy);
			}

			vertices ~= arr.toByte;
		}

		indices = makeIndices(tc);*/
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
				indices = indices.remove(i, i + 1, i + 2);
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

		Vector3*[][int[3]] aa;

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
