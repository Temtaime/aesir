module ro.conv;
import std.file, std.path, std.conv, std.range, std.getopt, std.process,
	core.memory, perfontain, perfontain.misc, ro.conv.asp, ro.conv.map,
	ro.conv.gui, ro.conv.all, ro.conv.item, ro.conv.effect, rocl.rofs, ro.paths;

/*auto convert(T)(string res, string path, bool delegate() checker = null)
{
	T value;

	switch(path.extension.drop(1))
	{
	case `aaf`:
		path = `effect/` ~ path;
		break;

	default:
	}

	if(path.tryLoad(value) && (!checker || checker()))
	{
		return value;
	}

	logger.info2(`converting %s...`, path);

	{
		[ thisExePath, `--res`, res, `--path`, path ].spawnProcess.wait;
	}

	path.tryLoad(value) || throwError(`conversion failed`);
	return value;
}*/

package:

abstract class Converter(T)
{
	T convert()
	{
		auto path = ``;

		try
		{
			return PEfs.read!T(path);
		}
		catch (Exception ex)
		{
			logger.warning(ex.msg);
		}

		auto res = process;
		PEfs.put(path, res.serializeMem);
		return res;
	}

	auto imageOf(RoPath s)
	{
		if (auto p = s in _images)
		{
			return *p;
		}

		auto im = new Image(PEfs.get(s));
		im.clean;

		return _images[s] = im;
	}

protected:
	T process();
private:
	//__gshared
	Image[RoPath] _images;
}

bool tryLoad(T)(string path, ref T res)
{
	try
	{
		res = PEfs.read!T(path);
		return true;
	}
	catch (Exception e)
	{
		logger.warning("can't load `%s', error: %s", path, e.msg);
	}

	return false;
}
