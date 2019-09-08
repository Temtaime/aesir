import std;


auto extensionsUsed =
[
	[ `GL_ARB_direct_state_access`, `required` ],
	[ `GL_ARB_shader_storage_buffer_object`, `required` ],
	//[ `GL_EXT_texture_compression_dxt1`, `required` ],

	[ `GL_ARB_shader_draw_parameters` ], // 7700, 410

	[ `GL_ARB_bindless_texture`,
									`glGetTextureSamplerHandleARB`,
									`glMakeTextureHandleResidentARB`,
									`glMakeTextureHandleNonResidentARB`,
									`glProgramUniformHandleui64ARB`,
									`glIsTextureHandleResidentARB`
																			], // 7700, 630
];

immutable dirsToSearch = [ `.`, `misc`, `nodes`, `managers`, `math` ];

auto toLoadFormat(string s)
{
	return "\t_" ~ s ~ " = cast(typeof(_" ~ s ~ "))load(`" ~ s ~ "`);";
}

void main()
{
	auto dir = `../../source/perfontain`;
	auto file = dir ~ `/opengl/functions.d`;

	if(file.exists)
	{
		file.remove;
	}

	auto aa =
	[
		[ `GLDEBUGPROC`, `void function(GLenum, GLenum, GLuint, GLenum, GLsizei, in GLchar *, in void *)` ],
		[ `GLvoid`, `void` ],
		[ `GLdouble`, `double` ],
		[ `GLenum`, `uint` ],
		[ `GLfloat`, `float` ],

		[ `GLintptr`, `size_t` ],
		[ `GLsizeiptr`, `size_t` ],

		[ `GLint64`, `long` ],
		[ `GLuint64`, `ulong` ],
		[ `GLint`, `int` ],
		[ `GLuint`, `uint` ],
		[ `GLsizei`, `uint` ],
		[ `GLbitfield`, `uint` ],
		[ `GLboolean`, `bool` ],
		[ `GLbyte`, `byte` ],
		[ `GLubyte`, `ubyte` ],
		[ `GLchar`, `char` ],
		[ `GLshort`, `short` ],
		[ `GLushort`, `ushort` ],
		[ `GLsync`, `size_t` ]
	];

	auto arr = [ `glext.h`, `glcorearb.h` ].map!(a => a.readText.splitLines).join;

	auto fs = arr
					.map!(a => a.strip)
					.filter!(a => a.startsWith(`GLAPI`))
					.map!(a => a.replace(`GLAPI `, ``))
					.map!(a => a.replace(`APIENTRY `, ``))
					.map!(a => a.replace(regex(`^const `), ``)) // FIXME
					.map!(a => a.replace(`const*`, `*`))
					.map!(a => a.replace(regex(`\s*\w+(,|\))`, `g`), `$1`))
					.map!(a => a.replace(`const`, `in`))
					.map!(a => a.replace(regex(`\s*\*\s*`, `g`), `*`))
					.map!(a => a.replace(regex(`(\S+)\s*\b(\w+)\s*(.+);`), `$1 function$3 $2;`))
					.array;

	string[string] fa;
	string[string] fd;

	foreach(s; fs)
	{
		foreach(a; aa)
		{
			s = s.replace(a[0], a[1]);
		}

		auto n = s.match(`(\w+);$`).captures[1];

		if(n == `glGetString`)
		{
			s = `const(char)* function(uint) glGetString;`; // FIXME
		}

		fa[n] = s;
	}

	foreach(s; arr)
	{
		auto m = s.match(regex(`^#define\s+(\w+)\s+((?:0x)?[\da-f]+)\s*$`, `im`)).captures;

		if(m.length && !m[1].startsWith(`GL_ARB`))
		{
			fd[m[1]] = m[2];
		}
	}

	auto s = dirEntries(dir, `*.d`, SpanMode.depth).filter!(a => a != `opengl.d`).map!(a => a.name.readText).join;

	string[] uf;

	foreach(k; fa.keys)
	{
		if(s.match(`\b` ~ k ~ `\b`)) uf ~= k;
	}

	auto o = File(file, `wb`);
	auto un = extensionsUsed.filter!(a => a.back != `required`);

	o.writeln("module perfontain.opengl.functions;\n");
	o.writeln("import\tstd.meta,
		std.conv,

		utils.except,
		derelict.sdl2.sdl,

		perfontain.opengl;\n\n");

	o.writeln("alias PERF_EXTENSIONS = AliasSeq!(" ~ un.map!(a => "`" ~ a.front ~ "`").join(`, `) ~ ");\n");
	o.writeln("__gshared bool\t" ~ extensionsUsed.map!(a => a.front).join(",\n\t\t\t\t") ~ ";\n");

	o.writeln("enum : uint\n{");

	foreach(k, v; fd)
	{
		try
		{
			if(s.match(`\b` ~ k ~ `\b`)) o.writefln("\t%s = 0x%s,", k, (v.startsWith(`0x`) ? v[2..$].to!long(16) : v.to!long).to!string(16));
		}
		catch(Exception)
		{
			v.writeln;
		}
	}

	o.write("}\n\nvoid hookGL()\n{");

	{
		o.writeln(extensionsUsed.filter!(a => a.back == `required`).map!(a => "\n\tSDL_GL_ExtensionSupported(`" ~ a.front ~ "`) || throwError(`extension %s is unsupported`, `" ~ a.front ~ "`);").join);

		o.writeln;
	}

	{
		auto exts = extensionsUsed.map!(a => a[1..$]).join;

		o.writeln(uf.filter!(a => !exts.canFind(a)).map!(a => a.toLoadFormat).join("\n"));
	}

	o.writeln("\n" ~ un.map!(a => a.length > 1
															? "\n\tif((" ~ a.front ~ " = !!SDL_GL_ExtensionSupported(`" ~ a.front ~ "`)) == true)\n\t{\n" ~ a[1..$].filter!(a => uf.canFind(a)).map!(a => "\t" ~ a.toLoadFormat ~ "\n").join ~ "\t}"
															: "\t" ~ a.front ~ " = !!SDL_GL_ExtensionSupported(`" ~ a.front ~ "`);").join("\n"));

	o.writeln("
	debug
	{
		enableDebug;
	}
}

debug
{
" ~ uf.map!(a => format("\tauto %1$s(string f = __FILE__, uint l = __LINE__, A...)(A args) out { checkError(`%1$s`, f, l); } body { return _%1$s(args); }", a)).join("\n") ~ "
}
else
{
" ~ uf.map!(a => format("\talias %1$s = _%1$s;", a)).join("\n") ~ "
}

__gshared extern(System) @nogc nothrow\n{");
	o.writeln(uf.map!(a => "\t" ~ fa[a].replace(regex(`(\w+);$`), `_$1;`)).join("\n"));

	o.writeln("}

//private:

auto load(in char* name)
{
	pragma(inline, false);

	auto ret = SDL_GL_GetProcAddress(name);
	ret || throwError(`can't load opengl function: %s`, name.to!string);
	return ret;
}");
}
