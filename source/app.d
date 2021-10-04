import core.sys.windows.windows, core.sys.posix.sys.resource, perfontain, ro.conv, rocl.rofs, rocl.game;

version (Windows)
{
	//pragma(linkerDirective, `"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'"`);
}

extern (C) __gshared
{
	bool rt_cmdline_enabled;
	bool rt_envvars_enabled;

	string[] rt_options = [`scanDataSeg=precise`, `gcopt=cleanup:finalize gc:precise`];

	export
	{
		int NvOptimusEnablement = 1;
		int AmdPowerXpressRequestHighPerformance = 1;
	}
}

void main(string[] args)
{
	version (Windows)
	{
		SetConsoleOutputCP(65001);
	}

	// {
	// 	import utile.db, utile.encoding;

	// 	scope db = new SQLite(`data/ro.db`);

	// 	auto res = db.query!(uint, string)(`select id, name from weapons`).array;

	// 	foreach (r; res)
	// 	{
	// 		auto data = r[1].encode(51949).toByte;

	// 		if (r[1] != data)
	// 		{
	// 			db.query(`update weapons set name = ? where id = ?`, data, r[0]);
	// 		}
	// 	}
	// }

	PEfs = new RoFileSystem;

	PE.doInit;
	RO.doInit;

	try
	{
		RO.run(args);
	}
	catch (Throwable e)
	{
		debug
		{
		}
		else
		{
			//errorReport(e);
		}

		showErrorMessage(e.msg);
	}
	finally
	{
		RO.destroy;
		PE.destroy;

		logger.msg(`shutdown complete`);
	}
}
