module perfontain.shader.defineprocessor;
import std.stdio, std.array, std.range, std.regex, std.string, std.algorithm, std.functional, pegged.grammar,
	perfontain, perfontain.shader.grammar, perfontain.shader.resource;

struct DefineProcessor
{
	auto process(ProgramSource ps)
	{
		string[string] res;

		auto arr = dataOf(ps);
		alias pred = a => a.name == `EXGL.Shader`;

		foreach (ref p; arr.filter!pred)
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
	static dataOf(ProgramSource ps)
	{
		if (auto p = ps in _shaders)
			return *p;

		auto r = EXGL(ps.shaderSource);
		r.successful || throwError!`shader %s: %s`(ps, r.failMsg);

		return _shaders[ps] = r.children.front.children;
	}

	auto entab(R)(R r, bool tab)
	{
		return r.map!(a => gen(a)).join("\n").splitLines
			.filter!(a => a.length)
			.map!(a => (tab ? "\t" : null) ~ a)
			.join("\n");
	}

	auto expand(string s)
	{
		while (true)
		{
			auto n = s;

			defs.byKeyValue
				.array
				.sort!((a, b) => a.key.length > b.key.length)
				.each!(a => n = n.replace(a.key, a.value));

			if (n == s)
				break;

			s = n;
		}

		return s;
	}

	string gen(in ParseTree p, bool tab = true)
	{
		switch (p.name)
		{
		case `EXGL.Cond`:
			auto r = !!(p.children.front.matches.front in defs) ^ (p.matches.front == `!`);

			if (r)
			{
				return gen(p.children[1], false);
			}
			else if (p.children.length > 2)
			{
				return gen(p.children.back, false);
			}

			break;

		case `EXGL.Vsfs`:
			auto v = !!(`VERTEX_SHADER` in defs);
			auto s = p.matches.back;

			return format("%s %s", v ? `out` : `in`, s);

		case `EXGL.TexId`:
			auto s = p.matches.back;

			auto m = s.match(`(\w+);$`);
			assert(m);

			return format!`layout(binding = %u) %s`(texId(m.captures.back), s);

		case `EXGL.SsboId`:
			auto s = p.matches.back;

			auto m = s.match(`^buffer\s+(\w+)$`);
			assert(m);

			return format!`layout(binding = %u) %s`(ssboId(m.captures.back), s);

		case `EXGL.Import`:
			string name = p.matches.front;
			return entab(dataOf(name.programSource), false);

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

	auto texId(string name)
	{
		const k = SHADER_TEX_NAMES.countUntil(name);
		assert(k >= 0, name);

		return cast(ubyte)k;
	}

	auto ssboId(string name)
	{
		const k = SHADER_SSBO_NAMES.countUntil(name);
		assert(k >= 0, name);

		return cast(ubyte)k;
	}

	__gshared ParseTree[][ProgramSource] _shaders;
}
