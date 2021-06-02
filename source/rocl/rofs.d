module rocl.rofs;
import std, perfontain, perfontain.misc.rc, perfontain.filesystem, ro.grf, ro.conf, rocl.game, rocl.paths,
	utile.except, utile.logger, utile.miniz : Zip;

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

	override ubyte[] get(string name)
	{
		debug
		{
		}
		else
		{
			if (auto data = _zip.get(name).ifThrown(null))
			{
				return data;
			}
		}

		if (auto data = super.get(`tmp/` ~ name))
		{
			return data;
		}

		return super.get(name);
	}

	override void put(string name, in void[] data, ubyte t = FS_DISK)
	{
		super.put(`tmp/` ~ name, data, t);
	}

private:
	Zip _zip;
	RCArray!Grf _arr;
}
