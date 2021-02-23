module perfontain.misc.draw;
import std, core.stdc.stdlib, perfontain, perfontain.opengl;

final class DrawAllocator : RCounted
{
	this(ubyte type)
	{
		iv = new IndexVertex(type);
	}

	// RULES:
	// All the nodes are using same mesh holder
	// A texture cannot be repeated in submeshes
	// If bindless is not present, mesh must contain only one submesh
	//
	//
	//
	//
	//

	void draw(Program pg, in DrawInfo[] nodes, uint submeshes, bool bind)
	in
	{
		assert(nodes[1 .. $].all!(a => a.mh is nodes[0].mh));

		assert(nodes.map!(a => a.mh.meshes[a.id].subs)
				.all!(a => a.map!(s => cast()s.tex)
					.array
					.sort
					.group
					.all!(g => g[1] == 1)));
	}
	do
	{
		_drawnTriangles = 0;
		_drawnNodes = cast(uint)nodes.length;

		pg.bind;
		iv.bind;

		const off = nodes[0].mh.reg.index.start;

		if (GL_ARB_shader_draw_parameters)
		{
			uint k;

			if (bind)
			{
				foreach (arr; SubMeshRange(nodes).chunkBy!((a, b) => a.tex is b.tex))
				{
					uint cnt;
					pg.send(`pe_base_draw_id`, k);

					uint[] counts;
					size_t[] starts;

					foreach (sm; arr)
					{
						if (!cnt)
							sm.tex.bind(0);

						cnt++;
						counts ~= sm.len;
						starts ~= off + sm.start * 4;
					}

					glMultiDrawElements(GL_TRIANGLES, counts.ptr,
							GL_UNSIGNED_INT, cast(void**)starts.ptr, cnt);
					k += cnt;
				}
			}
			else
			{
				auto counts = ScopeArray!uint(submeshes);
				auto starts = ScopeArray!size_t(submeshes);

				foreach (sm; SubMeshRange(nodes))
				{
					counts[k] = sm.len;
					starts[k++] = off + sm.start * 4;

					_drawnTriangles += sm.len / 3;
				}

				glMultiDrawElements(GL_TRIANGLES, counts[].ptr,
						GL_UNSIGNED_INT, cast(void**)starts[].ptr, submeshes);
			}

			assert(k == submeshes);
		}
		else
		{
			int node = -1; // TODO: REFACTOR

			foreach (arr; SubMeshRange(nodes).chunkBy!((a, b) => a.tex is b.tex))
			{
				if (bind)
					arr.front.tex.bind(0);

				foreach (sm; arr)
				{
					if (node != sm.node)
						pg.send(`pe_object_id`, node = sm.node);

					glDrawElements(GL_TRIANGLES, sm.len, GL_UNSIGNED_INT,
							cast(void*)(off + sm.start * 4));
				}
			}
		}
	}

	RC!IndexVertex iv;
private:
	mixin publicProperty!(uint, `drawnNodes`);
	mixin publicProperty!(uint, `drawnTriangles`);

	struct SubMeshRange
	{
		this(in DrawInfo[] nodes)
		{
			_nodes = nodes;
		}

		bool empty()
		{
			return _node == _nodes.length;
		}

		auto front()
		{
			auto mesh = node.mh.meshes[node.id];

			auto sub = cast()mesh.subs[_sub];
			auto tex = cast()node.mh.texs[sub.tex];

			return tuple!(`tex`, `start`, `len`, `node`)(tex, sub.start, sub.len, _node);
		}

		void popFront()
		{
			auto mesh = node.mh.meshes[node.id];

			if (_sub == mesh.subs.length - 1)
			{
				_sub = 0;
				_node++;
			}
			else
				_sub++;
		}

	private:
		auto node()
		{
			return _nodes[_node];
		}

		uint _node, _sub;
		const(DrawInfo)[] _nodes;
	}
}
