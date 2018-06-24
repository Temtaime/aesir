module perfontain.misc.vmem;

import
		std.range,
		std.typecons,
		std.algorithm,

		core.stdc.stdlib,

		perfontain.vbo,
		perfontain.misc,
		perfontain.misc.rc,

		utils.logger;

public import
				perfontain.misc.vmem.region;


final class VMemAlloc : RCounted
{
	this(byte t)
	{
		vbo = new VertexBuffer(t);
	}

	~this()
	{
		assert(!_used);
	}

	auto alloc(in ubyte[] data)
	{
		assert(data.length);

		int idx = -1;

		auto p = find(cast(uint)data.length, idx);
		auto r = new AllocRegion(p, 0, data);

		if(idx >= 0)
		{
			_regs.insertInPlace(idx, r);
		}
		else
		{
			_regs ~= r;
		}

		_used += data.length;
		return r;
	}

	void free(in AllocRegion* r)
	{
		_used -= r.data.length;
		_regs = _regs.remove(_regs.countUntil!(a => a is r));

		auto a = vbo.alignment;
		auto n = (_used + _used / 4 + a - 1) / a * a;

		if(vbo.length > n)
		{
			compact(n);
		}
	}

	void update(AllocRegion* r)
	{
		write(r.data, r.value, r.start);
	}

	RC!VertexBuffer vbo;
private:
	void write(const(void)[] data, uint v, uint p)
	{
		if(v)
		{
			auto old = data.as!uint;
			auto tmp = ScopeArray!uint(data.length / 4);

			foreach(i, ref e; tmp)
			{
				e = old[i] + v;
			}

			vbo.update(tmp[], p);
		}
		else
		{
			vbo.update(data, p);
		}
	}

	void compact(uint len)
	{
		auto ow = len != vbo.length;

		if(ow)
		{
			vbo.realloc(_used + len);
		}

		uint p;

		foreach(r; _regs)
		{
			auto nq = r.start != p;

			if(nq || ow)
			{
				if(nq)
				{
					r.start = p;

					if(r.onMove)
					{
						r.onMove();
					}
				}

				update(r);
			}

			p = cast(uint)(r.start + r.data.length);
		}
	}

	uint find(uint len, ref int idx)
	{
		if(vbo.length - _used >= len)
		{
			uint p;

			foreach(i, r; _regs)
			{
				if(r.start != p)
				{
					if(r.start - p >= len)
					{
						idx = cast(int)i;
						return p;
					}
				}

				p = cast(uint)(r.start + r.data.length);
			}

			if(vbo.length - p >= len)
			{
				return p;
			}
		}

		compact(_used + len);
		return _used;
	}

	uint _used;
	AllocRegion*[] _regs;
}
