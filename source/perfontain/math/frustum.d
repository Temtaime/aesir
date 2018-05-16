module perfontain.math.frustum;

import
		perfontain.math.bbox,
		perfontain.math.matrix;


struct FrustumCuller
{
	this(ref in Matrix4 m)
	{
		foreach(i; 0..6)
		foreach(j; 0..4)
		{
			auto k = j * 4;

			auto a = m.flat[3 + k];
			auto b = m.flat[i / 2 + k];

			_planes[i][j] = i % 2 ? a + b : a - b;
		}
	}

	const collision()(auto ref in BBox box)
	{
		ubyte c;

		foreach(ref f; _planes)
		{
			ubyte k;

			static foreach(n; 0..8)
			{
				if(f.p * box.point!n + f.w > 0)
				{
					k++;
				}
			}

			if(!k)
			{
				return F_OUTSIDE;
			}

			c += k == 8;
		}

		return c == 6 ? F_INSIDE : F_INTERSECTS;
	}

package:
	Vector4[6] _planes;
}
