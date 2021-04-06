module rocl.rofs;
import std, perfontain, perfontain.misc.rc, perfontain.filesystem, ro.grf,
	ro.conf, rocl.game, rocl.paths, utile.except, utile.logger, utile.miniz : Zip;

final class RoFileSystem : FileSystem
{
	this()
	{
		debug
		{
		}
		else
		{
			_zip = new Zip(RES_FILE, false);
		}
	}

	~this()
	{
		_zip.destroy;
	}

	auto grfs()
	{
		if (!_arr.length)
		{
			auto t = TimeMeter(`loading grf files`);

			_arr = RO.settings.grfs.map!(a => new Grf(a)).array;
		}

		return _arr[];
	}

	T read(T)(RoPath p)
	{
		return get(p).deserializeMem!T;
	}

	const(void)[] get(RoPath p)
	{
		foreach (grf; grfs)
			if (auto data = grf.get(p))
				return data;

		throwError!`file %s is not found in GRFs`(p);
		assert(0);
	}

protected:
	override void doRead(string name, Rdg dg)
	{
		if (auto data = _zip.get(name).ifThrown(null))
		{
			return dg(data, false);
		}

		try
		{
			return super.doRead(`tmp/` ~ name, dg);
		}
		catch (Exception)
		{
			return super.doRead(name, dg);
		}
	}

	override void doWrite(string name, Wdg dg, ubyte t)
	{
		super.doWrite(`tmp/` ~ name, dg, t);
	}

private:
	Zip _zip;
	RCArray!Grf _arr;
}
