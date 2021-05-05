module perfontain.shader.lang;
import std.conv, std.string, std.algorithm, perfontain, perfontain.opengl,
	perfontain.shader.types, perfontain.shader.defineprocessor;

struct ProgramCreator
{
	this(string n)
	{
		logger.info2(`creating %s shader`, _name = n);

		define(`VIEWPORT_SIZE`, PEwindow._size);
	}

	void define(string s)
	{
		_dp.defs[s] = null;
	}

	void define(string s, int v)
	{
		_dp.defs[s] = v.to!string;
	}

	void define(string s, float v)
	{
		_dp.defs[s] = format(`float(%g)`, v);
	}

	void define(string s, ref in Vector3 v)
	{
		_dp.defs[s] = format(`vec3(%(%s, %))`, v.flat);
	}

	void define(string s, ref in Vector2s v)
	{
		_dp.defs[s] = format(`ivec2(%(%s, %))`, v.flat);
	}

	auto create()
	{
		RCArray!Shader res;
		auto aa = _dp.process(_name);

		foreach (t, s; aa)
		{
			auto data = replace(s ~ "\n", "\n", "\r\n");

			debug
			{
				PEfs.put(format(`shader/%s_%s.c`, _name, t), data);
			}

			auto tp = cast(ubyte)shaderNames.countUntil(t);
			res ~= new Shader(_name, data, tp);
		}

		auto shaders = res[];
		return new Program(shaders);
	}

private:
	string _name;
	DefineProcessor _dp;
}
