module perfontain.shader.resource;
import std, perfontain;

enum ProgramSource
{
	depth,
	light_compute,
	gui,
	draw
}

string shaderSource(ProgramSource ps, string type)
{
	final switch (ps)
	{
	case ProgramSource.depth:
		return type == `vertex` || type == `fragment` ? resource(`depth`, import(`depth.c`)) : null;
	case ProgramSource.light_compute:
		return type == `compute` ? resource(`light_compute`, import(`light_compute.c`)) : null;
	case ProgramSource.gui:
		return type == `vertex` || type == `fragment` ? resource(`gui`, import(`gui.c`)) : null;
	case ProgramSource.draw:
		return type == `vertex` || type == `fragment` ? resource(`draw`, import(`draw.c`)) : null;
	}
}

string shaderInclude(string name)
{
	assert(name == `lighting`);
	return resource(`lighting`, import(`lighting.c`));
}

private string resource(string name, string data)
{
	debug return PEfs.get(`../source/perfontain/shader/res/` ~ name ~ `.c`).assumeUTF;
	else return data;
}

extern (C++) int shaderc_main(int, const(char)**);
