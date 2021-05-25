module perfontain.program;
import std, core.bitop, perfontain.opengl, perfontain, utile.except, utile.logger;
public import perfontain.program.props;

enum
{
	PROG_DATA_MODEL = 1,
	PROG_DATA_COLOR = 2,
	PROG_DATA_NORMAL = 4,
	PROG_DATA_LIGHTS = 8,
	PROG_DATA_SM_MAT = 16,
	PROG_DATA_SCISSOR = 32,
}

struct Attrib
{
	uint type, size;
}

final class Program : RCounted
{
	this(Shader[] shaders)
	{
		_id = glCreateProgram();

		shaders.each!(a => glAttachShader(_id, a.id));
		doLink;
		shaders.each!(a => glDetachShader(_id, a.id));

		parseAttribs;
		debug logger(_attribs);

		static immutable Attrs = [
			tuple(`pe_transforms.pe_shadow_matrix`, PROG_DATA_SM_MAT),
			tuple(`pe_transforms.transforms[0].model`, PROG_DATA_MODEL),
			tuple(`pe_transforms.transforms[0].color`, PROG_DATA_COLOR),
			tuple(`pe_transforms.transforms[0].normal`, PROG_DATA_NORMAL),
			tuple(`pe_transforms.transforms[0].scissor`, PROG_DATA_SCISSOR),
			tuple(`pe_transforms.transforms[0].lightStart`, PROG_DATA_LIGHTS),
		];

		foreach (a; Attrs)
		{
			if (a[0] in _attribs)
			{
				_flags |= a[1];
			}
		}
	}

	~this()
	{
		unbind;

		foreach (u; _unis.values.filter!(a => a && a.idx >= 0))
		{
			glBindBufferBase(GL_SHADER_STORAGE_BUFFER, u.idx, 0);
			u.data = null;
		}

		_texs.each!(a => a.destroy);

		glDeleteProgram(_id);
	}

	void bind()
	{
		if (_init)
		{
			_init = false;

			debug foreach (name, attr; _attribs)
			{
				if (isSampler(attr.type))
				{
					const idx = cast(byte)SHADER_TEX_NAMES.countUntil(name);

					assert(idx >= 0, format!`unknown texture %s used`(name));
					assert(_texs.keys.canFind(idx), format!`texture %s was not bound`(name));
				}
			}

			foreach (id, tex; _texs)
			{
				const name = SHADER_TEX_NAMES[id];
				assert(_attribs.keys.canFind(name), format!`trying to bound extra texture %s`(name));

				tex.bind(id);
			}
		}

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
			if (!s)
				return;
		}

		static if (is(T : int))
		{
			glProgramUniform1i(_id, s.loc, value);
		}
		else static if (is(T == ulong))
		{
			glProgramUniform2uiv(_id, s.loc, 1, cast(uint*)&value);
		}
		else static if (is(T == Vector3))
		{
			glProgramUniform3fv(_id, s.loc, 1, value.ptr);
		}
		else static if (is(T == Vector4))
		{
			glProgramUniform4fv(_id, s.loc, 1, value.ptr);
		}
		else static if (is(T == Matrix4))
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

		if (auto s = locationOf(name, true))
		{
			bool b = !s.data;

			if (b)
				s.data = new VertexBuffer(-1, dynamic ? VBO_DYNAMIC : 0);

			s.data.realloc(cast(uint)data.length, data.ptr);
			glBindBufferBase(GL_SHADER_STORAGE_BUFFER, s.idx, s.data.id);

			// FIXME gles
			//if (b)
			//	glShaderStorageBlockBinding(_id, s.loc, s.idx);
		}
	}

	auto minLen(string name)
	{
		if (auto r = locationOf(name, true))
		{
			return r.len;
		}

		assert(false);
	}

	void add(ShaderTexture id, Texture tex)
	{
		*_texs.require(id, new RC!Texture) = tex;
	}

private:
	mixin publicProperty!(ubyte, `flags`);

	void doLink()
	{
		glLinkProgram(_id);

		{
			int ok;
			glGetProgramiv(_id, GL_LINK_STATUS, &ok);

			if (ok)
				return;
		}

		int len;
		glGetProgramiv(_id, GL_INFO_LOG_LENGTH, &len);

		auto msg = new char[len];
		glGetProgramInfoLog(_id, len, null, msg.ptr);

		throwError!`cannot link program: %s`(msg[0 .. $ - 1].assumeUnique);
	}

	void parseAttribs()
	{
		enum Attribs = [
				tuple(GL_ACTIVE_UNIFORMS, GL_ACTIVE_UNIFORM_MAX_LENGTH, `glGetActiveUniform`),
				tuple(GL_ACTIVE_ATTRIBUTES, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, `glGetActiveAttrib`),
			];

		static foreach (e; Attribs)
		{
			{
				int cnt, nameLen;

				glGetProgramiv(_id, e[0], &cnt);
				glGetProgramiv(_id, e[1], &nameLen);

				auto name = new char[nameLen];

				foreach (i; 0 .. cnt)
				{
					int size;
					uint type;

					mixin(e[2] ~ `(_id, i, cast(uint)name.length, cast(uint*)&nameLen, &size, &type, name.ptr);`);

					_attribs[name[0 .. nameLen].idup] = Attrib(type, size);
				}
			}
		}

		{
			int cnt;
			glGetProgramInterfaceiv(_id, GL_SHADER_STORAGE_BLOCK, GL_ACTIVE_RESOURCES, &cnt);

			foreach (idx; 0 .. cnt)
			{
				parseBlock(idx);
			}
		}

		_attribs.rehash;
	}

	void parseBlock(uint idx)
	{
		int cnt;

		{
			const param = GL_NUM_ACTIVE_VARIABLES;
			glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1, &param, 1, null, &cnt);
		}

		if (!cnt)
			return;

		{
			int nameLen;

			const param = GL_NAME_LENGTH;
			glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1, &param, 1, null, &nameLen);

			auto name = new char[nameLen];
			glGetProgramResourceName(_id, GL_SHADER_STORAGE_BLOCK, idx, nameLen, null, name.ptr);

			_ssbo ~= name[0 .. $ - 1].assumeUnique;
		}

		auto vars = new int[cnt];

		{
			const param = GL_ACTIVE_VARIABLES;
			glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1, &param, cnt, null, vars.ptr);
		}

		foreach (var; vars)
		{
			static immutable props = [GL_NAME_LENGTH, GL_TYPE, GL_ARRAY_SIZE];
			enum N = cast(uint)props.length;

			int[N] arr;
			glGetProgramResourceiv(_id, GL_BUFFER_VARIABLE, var, N, props.ptr, N, null, arr.ptr);

			auto name = new char[arr[0]];
			glGetProgramResourceName(_id, GL_BUFFER_VARIABLE, var, arr[0], null, name.ptr);

			auto elem = name[0 .. $ - 1];
			_attribs[format(`%s.%s`, _ssbo.back, elem)] = Attrib(arr[1], arr[2]);
		}
	}

	static bind(uint id)
	{
		//if(set(PEstate._prog, id))
		{
			glUseProgram(id);

			//foreach(p; _unis)
			//p.data.bind;
		}
	}

	auto locationOf(string name, bool ssb = false)
	{
		if (auto u = name in _unis)
		{
			return *u;
		}

		auto n = name.toStringz;
		int loc = ssb ? glGetProgramResourceIndex(_id, GL_SHADER_STORAGE_BLOCK, n) : glGetUniformLocation(_id, n);

		UniformData* s;

		if (loc < 0)
		{
			logger.warning("can't get %s location for `%s' variable", ssb ? `SSBO` : `uniform`, name);
			_attribs.logger;
		}
		else
		{
			s = new UniformData;
			s.loc = loc;

			if (ssb)
			{
				auto prop = GL_BUFFER_DATA_SIZE;

				glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, loc, 1, &prop, 1, null, &s.len);

				int idx;

				prop = GL_BUFFER_BINDING;
				glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, loc, 1, &prop, 1, null, &idx);

				s.idx = cast(ubyte)idx;
				//s.idx = 0;
				//s.idx = cast(byte)bsf(~_ssbo);
				//btc(&_ssbo, s.idx);
			}
		}

		_unis[name] = s;
		_unis.rehash;

		return s;
	}

	static isSampler(uint id)
	{
		static immutable uint[] samplers = [GL_SAMPLER_2D, GL_UNSIGNED_INT_SAMPLER_2D];
		return samplers.canFind(id);
	}

	struct UniformData
	{
		RC!VertexBuffer data;

		int loc, len;
		byte idx = -1;
	}

	uint _id;
	bool _init = true;

	string[] _ssbo;
	Attrib[string] _attribs;

	UniformData*[string] _unis;
	RC!Texture*[ShaderTexture] _texs;
}
