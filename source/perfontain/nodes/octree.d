module perfontain.nodes.octree;

import
		std,

		perfontain,
		perfontain.misc,
		perfontain.math.frustum;


final class OctreeNode : Node
{
	this(Node node)
	{
		_nodes = node.childs;
		_drawn.length = _nodes.length;

		_root.box = bbox = node.bbox;
		_root.nodes = iota(cast(uint)_nodes.length).array;

		create(_root);
	}

	override void draw(in DrawInfo* di)
	{

		check(_root, di);

		_drawn[] = false;
	}

private:
	enum DEPTH = 2;

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

	void create(ref Tree t, uint depth = DEPTH)
	{
		/*{
			BBox box;
			_nodes[].indexed(t.nodes).each!(a => box += a.bbox);

			t.box.min = t.box.min.zipMap!max(box.min);
			t.box.max = t.box.max.zipMap!min(box.max);
		}*/

		auto box = &t.box;
		auto center = box.center;

		//writefln(`%s %s`, t.nodes.length, *box);

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

			foreach(i; t.nodes)
			{
				if(b.collision(_nodes[i].bbox))
				{
					e.nodes ~= i;
				}
			}

			if(auto cnt = e.nodes.length)
			{
				if(depth)
				{
					create(e, depth - 1);
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
