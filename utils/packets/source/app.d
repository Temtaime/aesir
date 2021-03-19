import std.file, std.path, std.conv, std.stdio, std.array, std.regex,
	std.string, std.algorithm, pegged.grammar;

mixin(grammar(`
Packets:
	Main		< Rule+ eoi
	Rule		< (Name / Id) Field* ('(' Name ')')?

	Field		< '<' Name+ '>' '.' Type
	Type		< Len? Name '?'?

	Id			<~ [a-z0-9]+
	Name		< identifier
	Len			<~ digit+

	Spacing		<- (space / eol / Comment)*
	Comment		<~ "//" (!eol .)* eol
`));

enum TypeMap = [`L` : `int`, `W` : `short`, `B` : `ubyte`, `P` : `RoPos`];

auto gen(in ParseTree[] arr)
{
	return arr.map!(a => gen(a));
}

string gen(ref in ParseTree t)
{
	switch (t.name)
	{
	case `Packets.Main`:
		return t.children.gen.join("\n\n");

	case `Packets.Rule`:
		auto n = t.children.length > 1 && t.children.back.name == `Packets.Name`;
		auto v = n ? format("\n\tenum PK_NAME = `%s`;\n", t.children.back.matches.front) : null;

		return format("struct Pk%s\n{%s%-(\n\t%s%)\n\n\tmixin readableToString;\n}",
				t.children.front.gen, v, t.children[1 .. n ? $ - 1 : $].gen);

	case `Packets.Field`:
		return format("%s %s;", t.children.back.gen,
				t.children.front.gen ~ t.children[1 .. $ - 1].map!(a => a.gen.capitalize).join);

	case `Packets.Type`:
		auto u = t.children.back.gen;
		auto len = t.children.length > 1 ? t.matches.front : null;

		auto isStr = u == `S`;
		auto r = t.matches.back == `?`;

		if (u == `Z` || isStr)
		{
			assert(len || r);

			if (r)
				return `@(ToTheEnd` ~ (isStr ? null : `, ZeroTerminated`) ~ `) string`;

			return format(`@(ArrayLength!(_ => %s), ZeroTerminated) string`, len);
		}

		return format(`%s%s%s`, r ? "@ToTheEnd " : null, TypeMap.get(u, `Pk` ~ u),
				r ? `[]` : (len ? '[' ~ len ~ ']' : null));

	case `Packets.Id`:
	case `Packets.Name`:
		return t.matches.front;

	default:
		assert(false, t.name);
	}
}

void main()
{
	auto dir = thisExePath.dirName;

	auto data = buildPath(dir, `packets.txt`).readText;
	auto result = buildPath(dir, `../../source/rocl/network/packets.d`);

	auto t = Packets(data).children.front;
	auto s = "module rocl.network.packets;\n\nimport\n\t\tperfontain,\n\t\trocl.network.structs;\n\n\n"
		~ t.gen ~ "\n";

	s.toFile(result);
}
