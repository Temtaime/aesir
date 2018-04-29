import
		core.sys.windows.windows,
		core.sys.posix.sys.resource,

		perfontain,
		perfontain.misc.report,

		ro.conv,

		rocl.rofs,
		rocl.game;


extern(C) __gshared
{
	bool rt_cmdline_enabled = false;
	bool rt_envvars_enabled = false;
	string[] rt_options = [ `scanDataSeg=precise` ];

	export
	{
		uint
				NvOptimusEnablement = 1,
				AmdPowerXpressRequestHighPerformance = 1;
	}
}

void main(string[] args)
{
	SetConsoleOutputCP(65001);

	PEfs = new RoFileSystem;

	PE.doInit;
	RO.doInit;

	try
	{
		if(!processConv(args))
		{
			RO.run(args);
		}
	}
	catch(Throwable e)
	{
		debug
		{}
		else
		{
			errorReport(e);
		}

		showErrorMessage(e.toString);
	}
	finally
	{
		RO.destroy;
		PE.destroy;
	}

	log(`shutdown complete`);
}
