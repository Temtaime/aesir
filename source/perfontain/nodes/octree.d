module perfontain.nodes.octree;

import
		std.math,
		std.range,
		std.stdio,
		std.algorithm,

		perfontain,
		perfontain.misc,
		perfontain.math.frustum;

enum
{
	DEPTH = 3,

	SPLIT_X = 2,
	SPLIT_Y = 2,

	K = SPLIT_X * SPLIT_Y,
}

final class OctreeNode : Node // TODO: disallow nodes with no children
{
	this(Node node)
	{
		// save nodes so there's a ref to each node
		_nodes = node.childs;

		// allocate array here
		_arr.length = (1 - K ^^ (DEPTH + 1)) / (1 - K);

		// bbox of a node must be valid
		create(bbox = node.bbox, DEPTH);
	}

	override void draw(in DrawInfo *di)
	{
		_di = di;
		test(0);

		foreach(n; _nodes)
		{
			n.flags &= ~NODE_INT_DRAWN;
		}
	}

private:
	void processNodes(S[] nodes, ubyte res)
	{
		foreach(ref s; nodes)
		{
			auto node = s.n;

			if(node.flags & NODE_INT_DRAWN)
			{
				continue;
			}

			switch(res) {
			case F_INTERSECTS:
				if(PEscene._culler.collision(node.bbox) == F_OUTSIDE)
				{
					break;
				}

				goto case;

			case F_INSIDE:
				node.draw(_di);
				break;

			default:
				if(!s.inside)
				{
					continue;
				}
			}

			node.flags |= NODE_INT_DRAWN;
		}
	}

	void test(uint idx)
	{
		auto s = &_arr[idx];
		auto res = PEscene._culler.collision(s.box);

		if(res == F_INTERSECTS)
		{
			idx = idx * K + 1;

			if(idx >= _arr.length)
			{
				processNodes(s.nodes, res);
			}
			else
			{
				foreach(c; 0..K) test(idx + c);
			}
		}
		else
		{
			processNodes(s.nodes, res);
		}
	}

	void create(ref in BBox bbox, ubyte depth, uint idx = 0)
	{
		{
			auto ap = appender!(S[]);

			foreach(n; _nodes)
			{
				if(auto res = bbox.collision(n.bbox))
				{
					ap.put(S(n, res == F_INSIDE));
				}
			}

			auto s = &_arr[idx];

			s.box = bbox;
			s.nodes = ap.data;

			if(!depth--)
			{
				return;
			}
		}

		uint c;
		auto d = bbox.size.xz;

		d.x /= SPLIT_X;
		d.y /= SPLIT_Y;

		foreach(x; 0..SPLIT_X)
		{
			auto xp = bbox.min.x + x * d.x;

			foreach(y; 0..SPLIT_Y)
			{
				auto yp = bbox.min.z + y * d.y;

				auto b = BBox(
								Vector3(xp, bbox.min.y, yp),
								Vector3(xp + d.x, bbox.max.y, yp + d.y)
																		);

				create(b, depth, idx * K + 1 + c++);
			}
		}
	}

	struct S
	{
		Node n;
		bool inside;
	}

	struct GroupTester
	{
		S[] nodes;
		BBox box;
	}

	const(DrawInfo) *_di;

	GroupTester[] _arr;
	RCArray!Node _nodes;
}
