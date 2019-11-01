module perfontain.program;

import
		std,

		core.bitop,

		perfontain.opengl,
		perfontain,

		utils.except,
		utils.logger;


enum
{
	PROG_DATA_MODEL		= 1,
	PROG_DATA_COLOR		= 2,
	PROG_DATA_NORMAL	= 4,
	PROG_DATA_LIGHTS	= 8,
	PROG_DATA_SM_MAT	= 16,
}

struct Attrib
{
	uint	type,
			size;
}

final class Program : RCounted
{
	this(Shader[] shaders)
	{
		_id = glCreateProgram();

		foreach(s; shaders)
		{
			glAttachShader(_id, s.id);
		}

		glLinkProgram(_id);

		foreach(s; shaders)
		{
			glDetachShader(_id, s.id);
		}

		parseAttribs;

		static immutable Attrs =
		[
			tuple(`pe_transforms.pe_shadow_matrix`, PROG_DATA_SM_MAT),
			tuple(`pe_transforms.transforms[0].model`, PROG_DATA_MODEL),
			tuple(`pe_transforms.transforms[0].color`, PROG_DATA_COLOR),
			tuple(`pe_transforms.transforms[0].normal`, PROG_DATA_NORMAL),
			tuple(`pe_transforms.transforms[0].lightStart`, PROG_DATA_LIGHTS),
		];

		foreach(a; Attrs)
		{
			if(a[0] in _attribs)
			{
				_flags |= a[1];
			}
		}
	}

	~this()
	{
		unbind;

		foreach(u; _unis.values.filter!(a => a && a.idx >= 0))
		{
			glBindBufferBase(GL_SHADER_STORAGE_BUFFER, u.idx, 0);

			u.data = null;
			btr(&_ssbo, u.idx);
		}

		glDeleteProgram(_id);
	}

	void bind()
	{
		bind(_id);
	}

	static unbind()
	{
		bind(0);
	}

	void send(T)(string name, auto ref in T value)
	{
		auto s = locationOf(name);

		debug
		{
			if(!s) return;
		}

		static if(is(T : int))
		{
			glProgramUniform1i(_id, s.loc, value);
		}
		else static if(is(T == ulong))
		{
			glProgramUniform2uiv(_id, s.loc, 1, cast(uint*)&value);
		}
		else static if(is(T == Vector3))
		{
			glProgramUniform3fv(_id, s.loc, 1, value.ptr);
		}
		else static if(is(T == Vector4))
		{
			glProgramUniform4fv(_id, s.loc, 1, value.ptr);
		}
		else static if(is(T == Matrix4))
		{
			glProgramUniformMatrix4fv(_id, s.loc, 1, false, value.ptr);
		}
		else
		{
			static assert(false);
		}
	}

	void ssbo(string name, in void[] data, bool dynamic = true)
	{
		assert(data.length);

		if(auto s = locationOf(name, true))
		{
			bool b = !s.data;

			if(b)
			{
				s.data = new VertexBuffer(-1, dynamic ? VBO_DYNAMIC : 0);
			}

			s.data.realloc(cast(uint)data.length, data.ptr);
			glBindBufferBase(GL_SHADER_STORAGE_BUFFER, s.idx, s.data.id);

			if(b)
			{
				glShaderStorageBlockBinding(_id, s.loc, s.idx);
			}
		}
	}

	auto minLen(string name)
	{
		if(auto r = locationOf(name, true))
		{
			return r.len;
		}

		assert(false);
	}

private:
	mixin publicProperty!(ubyte, `flags`);

	void parseAttribs()
	{
		enum Attribs =
		[
			tuple(GL_ACTIVE_UNIFORMS, GL_ACTIVE_UNIFORM_MAX_LENGTH, `glGetActiveUniform`),
			tuple(GL_ACTIVE_ATTRIBUTES, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, `glGetActiveAttrib`),
		];

		static foreach(e; Attribs)
		{
			{
				int		cnt,
						nameLen;

				glGetProgramiv(_id, e[0], &cnt);
				glGetProgramiv(_id, e[1], &nameLen);

				auto name = new char[nameLen];

				foreach(i; 0..cnt)
				{
					int size;
					uint type;

					mixin(e[2] ~ `(_id, i, cast(uint)name.length, cast(uint*)&nameLen, &size, &type, name.ptr);`);

					_attribs[name[0..nameLen].idup] = Attrib(type, size);
				}
			}
		}

		{
			int cnt;
			glGetProgramInterfaceiv(_id, GL_SHADER_STORAGE_BLOCK, GL_ACTIVE_RESOURCES, &cnt);

			foreach(idx; 0..cnt)
			{
				parseBlock(idx);
			}
		}

		_attribs.rehash;
	}

	void parseBlock(uint idx)
	{
		int		cnt,
				nameLen;

		glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1,  [ GL_NUM_ACTIVE_VARIABLES ].ptr, 1, null, &cnt);

		if(!cnt)
		{
			return;
		}

		glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1,  [ GL_NAME_LENGTH ].ptr, 1, null, &nameLen);

		auto block = new char[nameLen];
		glGetProgramResourceName(_id, GL_SHADER_STORAGE_BLOCK, idx, nameLen, cast(uint*)&nameLen, block.ptr);
		block.length = nameLen;

		auto vars = new int[cnt];
		glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1, [ GL_ACTIVE_VARIABLES ].ptr, cnt, null, vars.ptr);

		foreach(var; vars)
		{
			enum Query = [ GL_NAME_LENGTH, GL_TYPE, GL_ARRAY_SIZE ];
			enum N = cast(uint)Query.length;

			int[N] arr;
			glGetProgramResourceiv(_id, GL_BUFFER_VARIABLE, var, N, Query.ptr, N, null, arr.ptr);

			auto varName = new char[arr[0]];
			glGetProgramResourceName(_id, GL_BUFFER_VARIABLE, var, arr[0], cast(uint*)&nameLen, varName.ptr);

			_attribs[format(`%s.%s`, block, varName[0..nameLen])] = Attrib(arr[1], arr[2]);
		}
	}

	static bind(uint id)
	{
		//if(set(PEstate._prog, id))
		{
			glUseProgram(id);
		}
	}

	auto locationOf(string name, bool ssb = false)
	{
		if(auto u = name in _unis)
		{
			return *u;
		}

		auto n = name.toStringz;
		int loc = ssb ? glGetProgramResourceIndex(_id, GL_SHADER_STORAGE_BLOCK, n) : glGetUniformLocation(_id, n);

		UniformData *s;

		if(loc < 0)
		{
			logger.warning("can't get %s location for `%s' variable", ssb ? `SSBO` : `uniform`, name);
		}
		else
		{
			s = new UniformData;
			s.loc = loc;

			if(ssb)
			{
				auto prop = GL_BUFFER_DATA_SIZE;
				glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, loc, 1, &prop, 1, null, &s.len);

				s.idx = cast(byte)bsf(~_ssbo);
				btc(&_ssbo, s.idx);
			}
		}

		_unis[name] = s;
		_unis.rehash;

		return s;
	}

	struct UniformData
	{
		RC!VertexBuffer data;

		int
			loc,
			len;

		byte idx = -1;
	}

	__gshared size_t _ssbo;

	uint _id;

	Attrib[string] _attribs;
	UniformData*[string] _unis;
}
