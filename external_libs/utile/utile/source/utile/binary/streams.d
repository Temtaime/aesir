module utile.binary.streams;
import std.mmfile, utile.binary, utile.misc, utile.except;

struct MemoryStream
{
	this(in void[] data)
	{
		_p = cast(ubyte*)data.ptr;
		_end = _p + data.length;
	}

	bool read(ubyte[] v)
	{
		if (length < v.length)
			return false;

		v[] = _p[0 .. v.length];
		_p += v.length;

		return true;
	}

	bool read(ref ubyte[] v, size_t len)
	{
		if (length < len)
			return false;

		v = _p[0 .. len].dup;
		_p += len;

		return true;
	}

	bool readstr(E)(ref E[] v, size_t maxLen)
	{
		auto start = cast(E*)_p;

		auto t = start;
		auto r = length / E.sizeof;

		for (; r && *t && maxLen; r--, t++, maxLen--)
		{
		}

		if (r || !maxLen)
		{
			v = start[0 .. t - start].dup;
			_p = cast(ubyte*)(t + (maxLen ? 1 : 0));

			return true;
		}

		return false;
	}

	bool write(in ubyte[] v)
	{
		if (length < v.length)
			return false;

		_p[0 .. v.length] = v;
		_p += v.length;

		return true;
	}

	bool rskip(size_t cnt)
	{
		if (length < cnt)
			return false;

		_p += cnt;
		return true;
	}

	bool wskip(size_t cnt)
	{
		if (length < cnt)
			return false;

		_p += cnt;
		return true;
	}

	const data()
	{
		return _p[0 .. length];
	}

	const length()
	{
		return _end - _p;
	}

private:
	ubyte* _p, _end;
}

struct AppendStream
{
	bool write(in ubyte[] v)
	{
		data ~= v;
		return true;
	}

	bool wskip(size_t cnt)
	{
		data.length += cnt;
		return true;
	}

	const length()
	{
		return 0;
	}

	ubyte[] data;
}

struct LengthCalcStream
{
	bool write(in ubyte[] v)
	{
		_written += v.length;
		return true;
	}

	bool wskip(size_t cnt)
	{
		_written += cnt;
		return true;
	}

	const length()
	{
		return 0;
	}

private:
	mixin publicProperty!(size_t, `written`);
}
