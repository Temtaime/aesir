module perfontain.signals;

import
		std.array,
		std.range,
		std.algorithm,

		perfontain.misc.rc;


final class ConnectionPoint : RCounted
{
	this(void delegate() f)
	{
		_f = f;
	}

	~this()
	{
		disconnect;
	}

	void disconnect()
	{
		if(_f)
		{
			_f();
			_f = null;
		}
	}

private:
	void delegate() _f;
}

struct Signal(T, A...)
{
	alias F = T delegate(A);

	auto add(F f)
	{
		auto s = new S(f);

		auto u =
		{
			auto idx = _arr.countUntil(s);
			_arr = _arr.dup.remove(idx);
		};

		_arr ~= s;
		return new ConnectionPoint(u);
	}

	void permanent(F f)
	{
		_arr ~= new S(f);
	}

	/*auto add(F f)
	{
		auto d = (A args) { return f(args); };
		return add(f.toDelegate);
	}*/

	static if(is(T == bool))
	{
		void first(A args)
		{
			foreach(s; _arr)
			{
				if(s.f(args)) break;
			}
		}

		void last(A args)
		{
			foreach_reverse(s; _arr)
			{
				if(s.f(args)) break;
			}
		}
	}

	void latest(A args)
	{
		if(_arr.length)
		{
			_arr.back.f(args);
		}
	}

	void opCall()(A args)
	{
		_arr.each!(a => a.f(args));
	}

	void reverse(A args)
	{
		_arr.retro.each!(a => a.f(args));
	}

private:
	struct S
	{
		F f;
	}

	S *[] _arr;
}
