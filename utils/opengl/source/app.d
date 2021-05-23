import std;

immutable dirsToSearch = [`.`, `misc`, `nodes`, `managers`, `math`];

auto toLoadFormat(string s)
{
	return "\t_" ~ s ~ " = cast(typeof(_" ~ s ~ "))load(`" ~ s ~ "`);";
}

void main()
{
	auto dir = `../../source/perfontain`;
	auto file = dir ~ `/opengl/functions.d`;

	if (file.exists)
	{
		file.remove;
	}

	auto aa = [
		[
			`GLDEBUGPROC`,
			`void function(GLenum, GLenum, GLuint, GLenum, GLsizei, in GLchar *, in void *)`
		], [`GLvoid`, `void`], [`GLdouble`, `double`], [`GLenum`, `uint`],
		[`GLfloat`, `float`], [`GLintptr`, `size_t`], [`GLsizeiptr`,
			`size_t`], [`GLint64`, `long`], [`GLuint64`, `ulong`], [
			`GLint`, `int`
		], [`GLuint`, `uint`], [`GLsizei`, `uint`], [`GLbitfield`, `uint`],
		[`GLboolean`, `bool`], [`GLbyte`, `byte`], [`GLubyte`, `ubyte`],
		[`GLchar`, `char`], [`GLshort`, `short`], [`GLushort`, `ushort`],
		[`GLsync`, `size_t`]
	];

	auto files = [
		`include/GLES2/gl2.h`, `include/GLES2/gl2ext.h`,
		`include/GLES2/gl2ext_angle.h`, `include/GLES3/gl3.h`,
		`include/GLES3/gl31.h`
	].map!readText;

	string[] fs;

	foreach (s; files)
	{
		auto matches = s.matchAll(regex(`^\s*GL_APICALL\s+(.+?);`, `sm`))
			.map!(a => a.captures[1].splitLines.join);

		fs ~= matches.map!(a => a.replace(`GL_APIENTRY `, ``))
			.map!(a => a.replace(regex(`^const `), ``))
			.map!(a => a.replace(`const*`, `*`))
			.map!(a => a.replace(regex(`const\s+(\w+)\s*\*\s*const`, `g`), `in $1`))
			.map!(a => a.replace(regex(`\s*\w+(,|\))`, `g`), `$1`))
			.map!(a => a.replace(`const`, `in`))
			.map!(a => a.replace(regex(`\s*\*\s*`, `g`), `*`))
			.map!(a => a.replace(regex(`(\S+)\s*\b(\w+)\s*(.+)$`), `$1 function$3 $2;`))
			.array;
	}

	string[string] fa;
	string[string] fd;

	foreach (s; fs)
	{
		foreach (a; aa)
		{
			s = s.replace(a[0], a[1]);
		}

		auto n = s.match(`(\w+);$`).captures[1];

		if (n == `glGetString`)
		{
			s = `const(char)* function(uint) glGetString;`; // FIXME
		}

		fa[n] = s;
	}

	foreach (s; files)
	{
		auto matches = s.matchAll(regex(`^#define\s+(\w+)\s+((?:0x)?[\da-f]+)\s*$`, `im`));

		foreach (m; matches)
			if (m.length && !m[1].startsWith(`GL_ARB`))
			{
				fd[m[1]] = m[2];
			}
	}

	auto s = dirEntries(dir, `*.d`, SpanMode.depth).filter!(a => a != `opengl.d`)
		.map!(a => a.name.readText)
		.join;

	string[] uf;

	foreach (k; fa.keys)
	{
		if (s.match(`\b` ~ k ~ `\b`))
			uf ~= k;
	}

	auto o = File(file, `wb`);

	o.writeln("module perfontain.opengl.functions;");
	o.writeln("import\tstd.meta,
		std.conv,

		utile.except,
		derelict.sdl2.sdl,

		perfontain.opengl;

enum : uint\n{");

	foreach (k, v; fd)
	{
		try
		{
			if (s.match(`\b` ~ k ~ `\b`))
				o.writefln("\t%s = 0x%s,", k, (v.startsWith(`0x`)
						? v[2 .. $].to!long(16) : v.to!long).to!string(16));
		}
		catch (Exception)
		{
			v.writeln;
		}
	}

	o.writeln("}\n\nvoid hookGL()\n{");
	o.writeln(uf.map!(a => a.toLoadFormat).join("\n"));

	o.writeln("}

debug
{
" ~ uf.filter!(a => a != `glGetError`)
			.map!(a => format("\tauto %1$s(string f = __FILE__, uint l = __LINE__, A...)(A args) in { traceGL(`%1$s`, f, l, args); } out { checkError(`%1$s`, f, l, args); } do { return _%1$s(args); }",
				a))
			.join("\n") ~ "

	alias glGetError = _glGetError;
}
else
{
" ~ uf.map!(a => format("\talias %1$s = _%1$s;", a)).join("\n") ~ "
}

private:

__gshared extern(System) @nogc nothrow\n{");
	o.writeln(uf.map!(a => "\t" ~ fa[a].replace(regex(`(\w+);$`), `_$1;`)).join("\n"));

	o.writeln("}

auto load(in char* name)
{
	pragma(inline, false);

	auto ret = SDL_GL_GetProcAddress(name);
	ret || throwError(`can't load opengl function: %s`, name.to!string);
	return ret;
}");
}
