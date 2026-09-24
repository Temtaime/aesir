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
	final switch (name)
	{
	case `bgfx_shader`:
		return resource(`bgfx_shader`, import(`bgfx_shader.sh`), `sh`);
	case `bgfx_compute`:
		return resource(`bgfx_compute`, import(`bgfx_compute.sh`), `sh`);
	case `lighting`:
		return resource(`lighting`, import(`lighting.c`));
	case `varying`:
		return resource(`varying`, import(`varying.def.sc`), `def.sc`);
	case `varying_gui`:
		return resource(`varying_gui`, import(`varying_gui.def.sc`), `def.sc`);
	}
}

private string resource(string name, string data, string extension = `c`)
{
	debug return PEfs.get(`../source/perfontain/shader/resource/` ~ name ~ `.` ~ extension).assumeUTF;
	else return data;
}

extern (C++) int shaderc_main(int, const(char)**);
