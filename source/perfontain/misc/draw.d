module perfontain.misc.draw;
import std, core.stdc.stdlib, perfontain;

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

	void draw(Program pg, in DrawInfo[] nodes, uint submeshes, bool bind, in Matrix4 viewProj, ushort view)
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

		// bgfx binds geometry for every submission; it has no VAO bind step.

		uint k;
		const off = nodes[0].mh.reg.index.start;

		if (bind)
		{
			foreach (arr; SubMeshRange(nodes).chunkBy!((a, b) => a.tex is b.tex))
			{
				uint cnt;
				foreach (sm; arr)
				{
					if (!cnt)
					{
						auto tex = sm.tex;
						assert(tex); // TODO

						if (tex)
						{
							pg.add(ShaderTexture.main, tex);
							pg.bind;
						}
					}

					cnt++;
					auto node = nodes[sm.node];
					pg.submit(iv, off / 4 + sm.start, sm.len, node.matrix * viewProj, node.matrix, node.color, !!(node.flags & DI_NO_DEPTH), node.blendingMode != noBlending, view);
				}
				k += cnt;
			}
		}
		else
		{
			foreach (sm; SubMeshRange(nodes))
			{
				auto node = nodes[sm.node];
				pg.submit(iv, off / 4 + sm.start, sm.len, node.matrix * viewProj, node.matrix, node.color, !!(node.flags & DI_NO_DEPTH), node.blendingMode != noBlending, view);
				k++;

				_drawnTriangles += sm.len / 3;
			}

			pg.bind;
		}

		assert(k == submeshes);
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
