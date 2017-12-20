module ro.conv.all;

import
		std.conv,
		std.parallelism,

		perfontain,

		ro.db,
		ro.conv.item,

		rocl.paths;


void doConvert()
{
	/*auto db = new RoDb;

	db.update;

	scope(exit)
	{
		db.destroy;
	}

	auto t = TimeMeter(`converting items`);

	auto arr = db.query!string(`select distinct res from items;`);

	foreach(k; arr.parallel)
	{
		auto id = k[0];
		ItemConverter con;

		try
		{
			synchronized
			{
				con = new ItemConverter(id);
			}
		}
		catch
		{
			continue;
		}

		PEfs.put(itemPath(id), con.process);
	}*/
}
