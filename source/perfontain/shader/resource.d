module perfontain.shader.resource;

import
		std.string,

		perfontain;


shared static this()
{
	debug
	{}
	else
	{
		shaders =
		[
			`depth`: import(`depth.c`),
			`draw`: import(`draw.c`),
			`gui`: import(`gui.c`),
			`lighting`: import(`lighting.c`),
			`misc`: import(`misc.c`),
			`shadows`: import(`shadows.c`),
		];
	}
}

auto shaderSource(string name)
{
	debug
	{
		return PEfs.get(`../source/perfontain/shader/res/` ~ name ~ `.c`).assumeUTF;
	}
	else
	{
		return shaders[name];
	}
}

private:

__gshared immutable string[string] shaders;
