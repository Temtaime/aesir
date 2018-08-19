module perfontain.misc.report;

import
		std.conv,
		std.json,
		std.range,
		std.string,
		std.random,
		std.process,
		std.datetime,
		std.typecons,
		std.digest.md,
		std.algorithm,

		std.net.curl,
		std.windows.registry,

		perfontain.opengl,

		utils.misc,
		utils.logger;


version(none):

void configReport(string e, string v, string r, string g)
{
	auto id = md5Of(e ~ v ~ r ~ g).dup;

	if(queryBinary(`videoDriver`) != id)
	{
		string[] exts;

		{
			int n;
			glGetIntegerv(GL_NUM_EXTENSIONS, &n);

			exts = n
						.iota
						.map!(a => glGetStringi(GL_EXTENSIONS, a))
						.filter!(a => !!a)
						.map!(a => (cast(char *)a).fromStringz.idup.toLower)
						.array;
		}

		try
		{
			JSONValue j =
			[
				`vendor`: e,
				`version`: v,
				`renderer`: r,
				`glsl`: g,
			];

			j.object[`exts`] = exts;

			if(send(j).strip == `OK`)
			{
				updateBinary(`videoDriver`, id);
			}
		}
		catch(Exception)
		{}
	}
}

void errorReport(Throwable e)
{
	JSONValue j =
	[
		`error`: e.msg,
		`file`: e.file,
		`info`: e.info.toString
	];

	j.object[`line`] = cast(uint)e.line;
	send(j);
}

private:

auto compId()
{
	if(auto res = queryBinary(`compId`))
	{
		return res;
	}

	auto u = [ uniform!ulong, uniform!ulong ].toByte;

	updateBinary(`compId`, u);
	return u;
}

auto send(JSONValue j)
{
	j.object[`uid`] = compId.toHexString!(LetterCase.lower);

	try
	{
		auto data = [ `data`: j.toString ];
		return post(`aesir.perfontain.ru/report.php`, data);
	}
	catch(Exception)
	{}

	return null;
}

auto openKey()
{
	auto key = Registry.currentUser.getKey(`Software`);

	try
	{
		return key.getKey(`TT AEsir`, REGSAM.KEY_READ | REGSAM.KEY_WRITE);
	}
	catch(Exception)
	{
		return key.createKey(`TT AEsir`);
	}
}

auto updateBinary(string name, ubyte[] arr)
{
	openKey.setValue(name, arr.as!byte);
}

auto queryBinary(string name)
{
	try
	{
		auto res = openKey.getValue(name).value_BINARY.toByte;

		if(res.length == 16)
		{
			return res;
		}
	}
	catch(Exception)
	{}

	return null;
}
