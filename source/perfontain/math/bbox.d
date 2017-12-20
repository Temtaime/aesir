module perfontain.math.bbox;

import
		std.meta,
		std.range,
		std.string,
		std.traits,
		std.algorithm,

		perfontain.misc,
		perfontain.math.matrix;

enum : ubyte
{
	F_OUTSIDE,
	F_INTERSECTS,
	F_INSIDE
}

struct BBox
{
	this()(auto ref in Vector3 min_, auto ref in Vector3 max_)
	{
		min = min_;
		max = max_;
	}

	this()(auto ref in BBox b)
	{
		min = b.min;
		max = b.max;
	}

	this(R)(auto ref R r) if(isIterable!R)
	{
		r.each!(a => add(a.p));
	}

	ref opOpAssign(string op: `+`)(auto ref in BBox b)
	{
		return merge(b);
	}

	const
	{
		auto opBinary(string op: `+`)(auto ref in BBox b)
		{
			return BBox(this).merge(b);
		}

		auto opBinary(string op: `*`)(auto ref in Matrix4 m)
		{
			BBox r;

			foreach(v; staticMap!(point, IndexTuple!8).only)
			{
				r.add(v * m);
			}

			return r;
		}

		auto collision()(auto ref in BBox b)
		{
			if(	max.vfold!(Op!`>=`, Op!`&&`)(b.max) &&
				min.vfold!(Op!`<=`, Op!`&&`)(b.min))
			{
				return F_INSIDE;
			}

			return	max.vfold!(Op!`<`, Op!`||`)(b.min) ||
					min.vfold!(Op!`>`, Op!`||`)(b.max) ? F_OUTSIDE : F_INTERSECTS;
		}

		string toString() { return format(`[ min = %s, max = %s ]`, min, max); }

		@property
		{
			Vector3 size() { return max - min; }
			Vector3 center() { return min + range; }

			Vector3 range() { return size / 2; }
			Vector3 offset() { return (min + max) / 2; }
		}
	}

	Vector3
				min = MAX_VECTOR,
				max = -MAX_VECTOR;
private:
	enum MAX_VECTOR = Vector3(1e9);

	const point(ubyte N)()
	{
		Vector3 res;

		foreach(i; 0..3)
		{
			res[i] = (N & (2 ^^ i) ? max : min)[i];
		}

		return res;
	}

	void add(Vector3 p)
	{
		min = min.vmap!(std.algorithm.min)(p);
		max = max.vmap!(std.algorithm.max)(p);
	}

	ref merge(ref in BBox b)
	{
		min = min.vmap!(std.algorithm.min)(b.min);
		max = max.vmap!(std.algorithm.max)(b.max);

		return this;
	}
}
