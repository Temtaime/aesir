module perfontain.shader.defineprocessor;

import
		std.stdio,
		std.array,
		std.range,
		std.regex,
		std.string,
		std.algorithm,
		std.functional,

		pegged.grammar,

		perfontain,
		perfontain.shader.grammar,
		perfontain.shader.resource;


struct DefineProcessor
{
	auto process(string n)
	{
		string[string] res;

		auto arr = dataOf(n);
		alias pred = a => a.name == `EXGL.Shader`;

		foreach(ref p; arr.filter!pred)
		{
			auto old = defs.dup;
			auto t = p.matches.front;

			defs[t.toUpper ~ `_SHADER`] = null;
			res[t] = entab(chain(arr.filter!(not!pred), p.children), false);

			defs = old;
		}

		return res;
	}

	string[string] defs;
private:
	static dataOf(string n)
	{
		if(auto p = n in _shaders)
		{
			return *p;
		}

		auto r = EXGL(n.shaderSource);
		r.successful || throwError!`shader %s - %s`(n, r.failMsg);

		return _shaders[n] = r.children.front.children;
	}

	auto entab(R)(R r, bool tab)
	{
		return r
				.map!(a => gen(a))
				.join("\n")
				.splitLines
				.filter!(a => a.length)
				.map!(a => (tab ? "\t" : null) ~ a)
				.join("\n");
	}

	auto expand(string s)
	{
		while(true)
		{
			auto n = s;

			defs
				.byKeyValue
				.array
				.sort!((a, b) => a.key.length > b.key.length)
				.each!(a => n = n.replace(a.key, a.value));

			if(n == s)
			{
				break;
			}

			s = n;
		}

		return s;
	}

	string gen(ref in ParseTree p, bool tab = true)
	{
		switch(p.name)
		{
		case `EXGL.Cond`:
			auto r = !!(p.children.front.matches.front in defs) ^ (p.matches.front == `!`);

			if(r)
			{
				return gen(p.children[1], false);
			}
			else if(p.children.length > 2)
			{
				return gen(p.children.back, false);
			}

			break;

		case `EXGL.Vsfs`:
			auto v = !!(`VERTEX_SHADER` in defs);

			auto	s = p.matches.front,
					d = gen(p.children.front),
					n = p.matches.back;

			return format("%s %s\n{\n%s\n} %s;", v ? `out` : `in`, s, d, n);

		case `EXGL.Import`:
			return entab(dataOf(p.matches.front), false);

		case `EXGL.Block`:
			return entab(p.children, tab);

		case `EXGL.Data`:
			return expand(p.matches.front);

		case `EXGL.Define`:
			defs[p.matches.front] = null;
			break;

		case `EXGL.Assign`:
			auto n = p.matches.front;
			auto v = p.matches[1] == `+` ? defs.get(n, null) : null;

			defs[n] = v ~ p.matches.back;
			break;

		case `EXGL.Name`:
			return expand(defs.get(p.matches.front, null));

		default:
			assert(false, p.name);
		}

		return null;
	}

	__gshared ParseTree[][string] _shaders;
}
