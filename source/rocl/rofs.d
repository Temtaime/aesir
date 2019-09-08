module rocl.rofs;

import
		std,

		perfontain,

		perfontain.misc.rc,
		perfontain.filesystem,

		ro.grf,
		ro.conf,

		rocl.game,
		rocl.paths,

		utils.except,
		utils.logger,

		utils.miniz : Zip;


final class RoFileSystem : FileSystem
{
	this()
	{
		debug
		{}
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
		if(!_arr.length)
		{
			auto t = TimeMeter(`loading grf files`);

			_arr = RO.settings.grfs.map!(a => new Grf(a)).array;
		}

		return _arr[];
	}

protected:
	override void doRead(string name, Rdg dg)
	{
		try
		{
			return super.doRead(`tmp/` ~ name, dg);
		}
		catch(Exception)
		{}

		debug
		{}
		else
		{
			if(auto data = _zip.get(name).ifThrown(null))
			{
				return dg(data, false);
			}
		}

		try
		{
			super.doRead(name, dg);
		}
		catch(Exception e)
		{
			if(!PE.run || name.extension == `.wav` || name.extension == `.jpg`) // TODO: REMAKE
			{
				foreach(g; grfs)
				{
					if(auto data = g.get(name))
					{
						return dg(data, false);
					}
				}
			}

			throw e;
		}
	}

	override void doWrite(string name, Wdg dg, ubyte t)
	{
		//debug
		{
			super.doWrite(`tmp/` ~ name, dg, t);
		}
		//else
		//{
		//	if(t == FS_DISK)
		//	{
		//		_op.put(name, dg(null));
		//	}
		//	else
		//	{
		//		super.doWrite(name, dg, t);
		//	}
		//}
	}

private:
	Zip _zip;
	RCArray!Grf _arr;
}
