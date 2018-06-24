module ro.conv;

import
		std.file,
		std.path,
		std.conv,
		std.range,
		std.getopt,
		std.process,

		core.memory,

		perfontain,
		perfontain.misc,

		ro.conv.asp,
		ro.conv.map,
		ro.conv.gui,
		ro.conv.all,
		ro.conv.item,
		ro.conv.effect,

		rocl.rofs;


auto convert(T)(string res, string path, bool delegate() checker = null)
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
}

bool processConv(string[] args)
{
	try
	{
		bool all;

		string
				res,
				path;

		getopt(args, config.passThrough, `res`, &res, `path`, &path, `all`, &all);

		if(all)
		{
			doConvert;
		}
		else if(path.length)
		{
			Converter cv;

			try
			{
				switch(path.extension.drop(1))
				{
				case `roi`:
					//path = `icon/` ~ path;
					cv = new ItemConverter(res);
					break;

				case `rom`:
					//path = `map/` ~ path;
					cv = new RomConverter(res);
					break;

				case `asp`:
					//path = `sprite/` ~ path;
					cv = new AspConverter(res);
					break;

				case `aaf`:
					import ro.str;
					cv = new AafCreator(res);
					break;

				case `rog`:
					cv = new GuiConverter;
					break;

				default:
					throwError(`unknown extension`);
				}

				auto t = TimeMeter(`conversion`);
				PEfs.put(path, cv.process);
			}
			finally
			{
				cv.destroy;
			}
		}
		else
		{
			return false;
		}
	}
	catch(Throwable e)
	{
		logger.error(`%s`, e);
	}

	return true;
}

package:

abstract class Converter
{
	const(void)[] process();

	static imageOf(string s)
	{
		if(auto p = s in _images)
		{
			return *p;
		}

		auto im = new Image(PEfs.get(s));
		im.clean;

		return _images[s] = im;
	}

private:
	__gshared Image[string] _images;
}

bool tryLoad(T)(string path, ref T res)
{
	try
	{
		res = PEfs.read!T(path);
		return true;
	}
	catch(Exception e)
	{
		logger.warning("can't load `%s', error: %s", path, e.msg);
	}

	return false;
}
