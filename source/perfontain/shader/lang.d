module perfontain.shader.lang;

import
		std.conv,
		std.string,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		perfontain.shader.types,
		perfontain.shader.defineprocessor;


struct ProgramCreator
{
	this(string n)
	{
		logger.info2(`creating %s shader`, _name = n);
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

	auto create()
	{
		RCArray!Shader res;

		auto h = header;
		auto aa = _dp.process(_name);

		foreach(t, s; aa)
		{
			auto data = replace(h ~ s ~ "\n", "\n", "\r\n");

			debug
			{
				PEfs.put(format(`shader/%s_%s.c`, _name, t), data);
			}

			auto tp = cast(ubyte)shaderNames.countUntil(t);
			res ~= new Shader(_name, data, tp);
		}

		return new Program(res.data);
	}

private:
	auto header()
	{
		auto res = format("#version %u\n", OPENGL_VERSION * 10);

		foreach(ex; PERF_EXTENSIONS)
		{
			if(mixin(ex))
			{
				define(ex[7..$].toUpper);

				res ~= format("#extension %s : require\n", ex);
			}
		}

		res ~= "#extension GL_ARB_shader_image_load_store : require\n";
		res ~= "#extension GL_ARB_shading_language_420pack : require\n";
		res ~= "#extension GL_ARB_shader_storage_buffer_object : require\n";

		return res ~ "\n";
	}

	string _name;
	DefineProcessor _dp;
}
