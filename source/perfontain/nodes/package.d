module perfontain.nodes;

import

		std.stdio,
		std.range,
		std.algorithm,

		perfontain,
		perfontain.vbo,
		perfontain.mesh,
		perfontain.misc,
		perfontain.math.bbox,
		perfontain.config,
		perfontain.opengl,
		perfontain.math.matrix,
		perfontain.shader;


class Node : RCounted
{
	final
	{
		void recalcBBox()
		{
			childs.each!(a => bbox += a.bbox);
		}

		//const transBBox() { return bbox * matrix; }
	}

	void draw(in DrawInfo *di)
	{
		childs.each!(a => a.draw(di));
	}

	RCArray!Node childs;

	Matrix4 matrix;
	BBox bbox;

	ubyte flags;
}

enum
{
	NODE_INT_DRAWN		= 1, // TODO: make private somehow ???
}

final class ObjecterNode : Node
{
	override void draw(in DrawInfo *di)
	{
		auto m = PE.render.alloc;

		if(oris.length)
		{
			auto step = (PE._tick * 2) % oris.back.time;

			auto n = oris.countUntil!(a => a.time > step); // TODO: time check in the converter

			auto q1 = oris[n ? n - 1 : 0];
			auto q2 = oris[n];

			auto t = float(step - q1.time) / (q2.time - q1.time);

			auto q = q1.q * (1 - t) + q2.q * t;

			m.matrix = q.normalize.toMatrix * matrix * di.matrix;
		}
		else
		{
			m.matrix = matrix * di.matrix;
		}

		m.mh = mh;
		//m.depth = 0;
		m.color = colorWhite;
		m.blendingMode = noBlending;

		m.lightStart = lightStart;
		m.lightEnd = lightEnd;
		m.id = id;
		m.flags = di.flags;

		super.draw(m);
	}

	import ro.map; // TODO: remove
	RomFrameOrientation[] oris;

	RC!MeshHolder mh;
	Matrix4 matrix;

	uint lightStart, lightEnd;
	ushort id;
}
