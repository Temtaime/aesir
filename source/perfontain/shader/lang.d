module perfontain.shader.lang;
import std.conv, std.string, std.algorithm, std.file, perfontain, perfontain.shader.types;
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
		_defs[s] = null;
	}

	void define(string s, int v)
	{
		_defs[s] = v.to!string;
	}

	void define(string s, float v)
	{
		_defs[s] = format(`float(%g)`, v);
	}

	void define(string s, in Vector3 v)
	{
		_defs[s] = format(`vec3(%(%s, %))`, v.flat);
	}

	void define(string s, in Vector2s v)
	{
		_defs[s] = format(`ivec2(%(%s, %))`, v.flat);
	}

	auto create()
	{
		RCArray!Shader res;

		foreach (type, info; shaderInfo)
		{
			auto source = shaderSource(_ps, info.name);
			if (!source.length)
				continue;

			string data;
			foreach (name, value; _defs)
				data ~= `#define ` ~ name ~ (value.length ? ` ` ~ value : null) ~ '\n';
			data = replace(data ~ source ~ '\n', "\n", "\r\n");
			auto name = format(`shader/%s.glsl`, _ps);

			debug PEfs.put(name, data);

			res ~= new Shader(name, data, cast(ubyte)type);
		}

		auto shaders = res[];
		return new Program(shaders);
	}

private:
	ProgramSource _ps;
	string[string] _defs;
}
