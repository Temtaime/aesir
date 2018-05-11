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

	void unify()
	{
		while(unifySub) {}
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

private:
	bool unifySub()
	{
		struct S
		{
			uint idx;
			ubyte[3] verts;
		}

		auto tris = cast(Vertex[3][])asTriangles.array;

		int[5][3][] ts;
		S[][int[5][2]][bool] aa;

		foreach(idx, t; tris)
		{
			int[5][3] u;

			//auto wise = ((t[2].p - t[1].p) ^ (t[3].p - t[1].p)).z > 0;

			foreach(i, ref v; t)
			{
				float[5] arr;

				arr[0..3] = v.p.flat;
				arr[3..5] = v.t.flat;

				u[i] = arr.toInts;
			}

			foreach(p; 3.iota.permutations)
			{
				int[5][2] r;

				r[0] = u[p[0]];
				r[1] = u[p[1]];

				ubyte[3] arr =
				[
					cast(ubyte)p[0],
					cast(ubyte)p[1],
					cast(ubyte)p[2],
				];

				aa[true][r] ~= S(cast(uint)idx, arr);
			}
		}

		Vertex[] res;
		auto processed = new RedBlackTree!uint;

		bool changed;

		foreach(wise, q; aa)
		{
			foreach(ref cords, arr; q)
			{
				arr = arr.filter!(a => processed.equalRange(a.idx).empty).array;

				if(arr.empty)
				{
					continue;
				}

				if(arr.length == 1)
				{
					res ~= tris[arr[0].idx];
					processed.insert(arr[0].idx);
					continue;
				}

				auto rest = cartesianProduct(arr, arr).filter!(a => a[0].idx != a[1].idx);

				foreach(u, v; rest)
				{
					if(!processed.equalRange(u.idx).empty) continue;
					if(!processed.equalRange(v.idx).empty) continue;

					auto	a = tris[u.idx][u.verts[2]],
							b = tris[u.idx][u.verts[0]],
							c = tris[v.idx][v.verts[2]];

					if(arePointsOnOneLine(a.p, b.p, c.p))
					{
						auto e = (a.t - b.t) / (a.p - b.p).length * (a.p - c.p).length;

						import std.math;

						e.x = e.x.fabs;
						e.y = e.y.fabs;

						//e.writeln;

						e.x = a.u + (b.u > a.u ? e.x : -e.x);
						e.y = a.v + (b.v > a.v ? e.y : -e.y);

						if(valueEqual(c.u, e.x) && valueEqual(c.v, e.y))
						{
							res ~= a;
							res ~= tris[u.idx][u.verts[1]];
							res ~= c;

							processed.insert(u.idx);
							processed.insert(v.idx);

							changed = true;
						}
					}
				}
			}
		}

		vertices = res.toByte;
		indices = makeIndices(cast(uint)res.length / 3);

		return changed;
	}
}

struct SubMeshInfo
{
	Image tex;
	SubMeshData data;
}
