module perfontain.shader.lang;
import std.conv, std.string, std.algorithm, perfontain, perfontain.opengl, perfontain.shader.types, perfontain.shader.defineprocessor;
public import perfontain.shader.resource;

struct ProgramCreator
{
	this(ProgramSource ps)
	{
		logger.info2!`creating %s program`(_ps = ps);

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

	void define(string s, in Vector3 v)
	{
		_dp.defs[s] = format(`vec3(%(%s, %))`, v.flat);
	}

	void define(string s, in Vector2s v)
	{
		_dp.defs[s] = format(`ivec2(%(%s, %))`, v.flat);
	}

	auto create()
	{
		RCArray!Shader res;
		auto aa = _dp.process(_ps);

		foreach (t, s; aa)
		{
			auto data = replace(s ~ "\n", "\n", "\r\n");
			auto name = format(`shader/%s_%s.glsl`, _ps, t);

			debug PEfs.put(name, data);

			res ~= new Shader(name, data, t.shaderType);
		}

		auto shaders = res[];
		return new Program(shaders);
	}

private:
	ProgramSource _ps;
	DefineProcessor _dp;
}
