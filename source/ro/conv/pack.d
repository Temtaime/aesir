module ro.conv.pack;

import
		std.file,
		std.string,

		perfontain.misc.rc,

		ro.conf,
		rocl.opti,

		tt.logger;


void makeResPack()
{
	if(OPTI_FILE.exists)
	{
		OPTI_FILE.remove;
	}

	auto f = asRC(new Opti(OPTI_FILE, true));

	foreach(e; `data`.dirEntries(SpanMode.breadth))
	{
		if(e.isFile)
		{
			f.put(e.replace(`\`, `/`), read(e));
		}
	}
}
