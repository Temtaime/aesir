module perfontain.shader.resource;
import std, perfontain;

enum ProgramSource
{
	header,
	misc,
	depth,
	shadows,
	lighting,
	light_compute,
	gui,
	draw
}

ProgramSource programSource(string name)
{
	foreach (ps; EnumMembers!ProgramSource)
		if (ps.to!string == name)
			return ps;

	assert(false, name);
}

string shaderSource(ProgramSource pt)
{
	foreach (ps; EnumMembers!ProgramSource)
		if (ps == pt)
		{
			enum Name = ps.to!string ~ `.c`;

			debug return PEfs.get(`../source/perfontain/shader/res/` ~ Name).assumeUTF;
		else return import(Name);
		}

	assert(false);
}
