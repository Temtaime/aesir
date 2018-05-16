module perfontain.nodes.octree;

import
		std.experimental.all,

		perfontain,
		perfontain.misc,
		perfontain.math.frustum;


final class OctreeNode : Node
{
	this(Node node)
	{
		_nodes = node.childs;

		_root.box = bbox = node.bbox;
		_drawn.length = _nodes.length;

		create(_root);

		_drawn[] = false;
	}

	override void draw(in DrawInfo* di)
	{
		check(_root, di);

		_drawn[] = false;
	}

private:
	void check(ref Tree t, in DrawInfo* di)
	{
		if(auto res = PEscene._culler.collision(t.box))
		{
			if(res == F_INSIDE)
			{
				draw(t.nodes, di, true);
			}
			else
			{
				if(t.childs.length)
				{
					t.childs.each!((ref a) => check(a, di));
				}
				else
				{
					draw(t.nodes, di, false);
				}
			}
		}
	}

	void create(ref Tree t)
	{
		auto box = &t.box;
		auto center = _nodes[].map!(a => a.bbox.center).reduce!((a, b) => a + b) / _nodes.length;

		assert(box.hasInside(center));

		auto bb =
		[
			BBox(box.min,									Vector3(center.x, box.max.y, center.z)),
			BBox(Vector3(center.x, box.min.y, center.z),	box.max),
			BBox(Vector3(box.min.x, box.min.y, center.z),	Vector3(center.x, box.max.y, box.max.z)),
			BBox(Vector3(center.x, box.min.y, box.min.z),	Vector3(box.max.x, box.max.y, center.z)),
		];

		foreach(b; bb)
		{
			auto e = Tree(b);

			foreach(i, n; _nodes[].enumerate.filter!(a => !_drawn[a.index]))
			{
				if(auto res = b.collision(n.bbox))
				{
					if(res == F_INSIDE)
					{
						_drawn[i] = true;
					}

					e.nodes ~= cast(uint)i;
				}
			}

			if(auto cnt = e.nodes.length)
			{
				if(cnt < t.nodes.length && cnt > 16)
				{
					create(e);
				}

				t.childs ~= e;
			}
		}
	}

	void draw(uint[] arr, in DrawInfo* di, bool inside)
	{
		foreach(idx; arr)
		{
			if(!_drawn[idx] && (inside || PEscene._culler.collision(_nodes[idx].bbox)))
			{
				_drawn[idx] = true;
				_nodes[idx].draw(di);
			}
		}
	}

	struct Tree
	{
		BBox box;

		uint[] nodes;
		Tree[] childs;
	}

	Tree _root;

	BitArray _drawn;
	RCArray!Node _nodes;
}
