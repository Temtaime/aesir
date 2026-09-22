module perfontain.program;
import bgfx_c, std, core.bitop, perfontain, utile.except, utile.log;
public import perfontain.program.props;

enum
{
	PROG_DATA_MODEL = 1,
	PROG_DATA_COLOR = 2,
	PROG_DATA_NORMAL = 4,
	PROG_DATA_SM_MAT = 16,
	PROG_DATA_SCISSOR = 32,
}

/* Legacy OpenGL program linking and reflection retained until all shader paths use bgfx.
final class Program : RCounted
{
	this(Shader[] shaders)
	{
		_id = glCreateProgram();

		shaders.each!(a => glAttachShader(_id, a.id));
		doLink;
		shaders.each!(a => glDetachShader(_id, a.id));

		parseAttribs;

		static immutable Attrs = [
			tuple(`pe_transforms.pe_shadow_matrix`, PROG_DATA_SM_MAT),
			tuple(`pe_transforms.transforms[0].model`, PROG_DATA_MODEL),
			tuple(`pe_transforms.transforms[0].color`, PROG_DATA_COLOR),
			tuple(`pe_transforms.transforms[0].normal`, PROG_DATA_NORMAL),
			tuple(`pe_transforms.transforms[0].scissor`, PROG_DATA_SCISSOR),
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
		glDeleteProgram(_id);
	}

	void bind()
	{
		if (_init)
		{
			_init = false;
			doInitialize;
		}

		bindMainTexture;
		bind(_id);
	}

	static unbind()
	{
		bind(0);
	}

	void send(T)(string name, in T value)
	{
		int loc = _attribs[name].loc;

		static if (is(T : int))
		{
			glProgramUniform1i(_id, loc, value);
		}
		else static if (is(T == ulong))
		{
			glProgramUniform2uiv(_id, loc, 1, cast(uint*)&value);
		}
		else static if (is(T == Vector3))
		{
			glProgramUniform3fv(_id, loc, 1, value.ptr);
		}
		else static if (is(T == Vector4))
		{
			glProgramUniform4fv(_id, loc, 1, value.ptr);
		}
		else static if (is(T == Matrix4))
		{
			glProgramUniformMatrix4fv(_id, loc, 1, false, value.ptr);
		}
		else
			static assert(false);
	}

	auto minLen(string name) => _attribs[name].len;

	void add(ShaderTexture id, Texture tex)
	{
		if (_texs[id] != tex)
		{
			_texs[id] = tex;
		}
	}

	void add(ShaderBuffer id, VertexBuffer data)
	{
		_bufs[id] = data;
	}

private:
	mixin publicProperty!(ubyte, `flags`);

	void bindMainTexture()
	{
		enum N = ShaderTexture.main;
		auto tex = _texs[N];

		if (tex)
			tex.bind(N);
	}

	void doInitialize()
	{
		bool processSSBO(string name, uint type)
		{
			return name != SHADER_SSBO_NAMES[ShaderBuffer.transforms] && type == GL_SHADER_STORAGE_BLOCK;
		}

		bool processTexture(string name, uint type)
		{
			return only(GL_SAMPLER_2D, GL_UNSIGNED_INT_SAMPLER_2D).canFind(type);
		}

		initialize(&processSSBO, SHADER_SSBO_NAMES, `ssbo`, _bufs);
		initialize(&processTexture, SHADER_TEX_NAMES, `texture`, _texs);
	}

	void initialize(T)(bool delegate(string, uint) dg, immutable string[] arr, string type, ref T data)
	{
		debug foreach (name, attr; _attribs)
		{
			if (dg(name, attr.type))
			{
				const idx = cast(byte)arr.countUntil(name);

				assert(idx >= 0, format!`unknown %s %s used`(type, name));
				assert(data[idx], format!`%s %s was not bound`(type, name));
			}
		}

		foreach (ubyte id, ref e; data)
		{
			if (e)
			{
				const name = arr[id];
				assert(_attribs.keys.canFind(name), format!`trying to bound extra %s %s`(type, name));

				e.bind(id);
			}
		}
	}

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
		msg.length--;

		throwError!`cannot link program: %s`(msg.assumeUnique);
	}

	void parseVariable(alias F)(uint propCount, uint propNameLen, bool location)
	{
		int cnt, nameLen;

		glGetProgramiv(_id, propCount, &cnt);
		glGetProgramiv(_id, propNameLen, &nameLen);

		auto name = new char[nameLen];

		foreach (i; 0 .. cnt)
		{
			uint type;
			int size, loc;

			F(_id, i, cast(uint)name.length, cast(uint*)&nameLen, &size, &type, name.ptr);

			if (location)
				loc = glGetUniformLocation(_id, name.ptr);
			else
				loc = -1;

			_attribs[name[0 .. nameLen].idup] = Attrib(type, size, loc);
		}
	}

	void parseAttribs()
	{
		parseVariable!glGetActiveUniform(GL_ACTIVE_UNIFORMS, GL_ACTIVE_UNIFORM_MAX_LENGTH, true);
		parseVariable!glGetActiveAttrib(GL_ACTIVE_ATTRIBUTES, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, false);

		{
			int cnt;
			glGetProgramInterfaceiv(_id, GL_SHADER_STORAGE_BLOCK, GL_ACTIVE_RESOURCES, &cnt);

			foreach (idx; 0 .. cnt)
			{
				parseBlock(idx);
			}
		}

		debug
		{
			logger.msg!`parsed attribs: %s`(_attribs);
		}
	}

	auto parseBlockName(uint idx)
	{
		static immutable param = [GL_NAME_LENGTH, GL_BUFFER_DATA_SIZE];
		enum uint N = param.length;

		int[N] res;
		glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, N, param.ptr, N, null, res.ptr);

		const nameLen = res[0];
		const dataLen = res[1];

		auto name = new char[nameLen];
		glGetProgramResourceName(_id, GL_SHADER_STORAGE_BLOCK, idx, nameLen, null, name.ptr);
		name.length--;

		auto s = name.assumeUnique;
		_attribs[s] = Attrib(GL_SHADER_STORAGE_BLOCK, dataLen);

		return s;
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

		auto vars = new int[cnt];
		auto ssbo = parseBlockName(idx);

		{
			const param = GL_ACTIVE_VARIABLES;
			glGetProgramResourceiv(_id, GL_SHADER_STORAGE_BLOCK, idx, 1, &param, cnt, null, vars.ptr);
		}

		foreach (var; vars)
		{
			static immutable props = [GL_NAME_LENGTH, GL_TYPE, GL_ARRAY_SIZE];
			enum uint N = props.length;

			int[N] arr;
			glGetProgramResourceiv(_id, GL_BUFFER_VARIABLE, var, N, props.ptr, N, null, arr.ptr);

			auto elem = new char[arr[0]];
			glGetProgramResourceName(_id, GL_BUFFER_VARIABLE, var, arr[0], null, elem.ptr);
			elem.length--;

			_attribs[format(`%s.%s`, ssbo, elem)] = Attrib(arr[1], arr[2]);
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

	uint _id;
	bool _init = true;

	struct Attrib
	{
		uint type, len;
		int loc;
	}

	Attrib[string] _attribs;

	RC!Texture[ShaderTexture.max] _texs;
	RC!VertexBuffer[ShaderBuffer.max] _bufs;
}
*/

final class Program : RCounted
{
	this(Shader[] shaders)
	{
		assert(shaders.length == 2);

		_handle = bgfx_create_program(shaders[0].handle, shaders[1].handle, true);
		shaders.each!(a => a.relinquish);

		_mainTexture = bgfx_create_uniform(`s_texMain`.toStringz, BGFX_UNIFORM_TYPE_SAMPLER, 1);
	}

	~this()
	{
		bgfx_destroy_uniform(_mainTexture);
		bgfx_destroy_program(_handle);
	}

	void bind()
	{
	}

	static void unbind()
	{
	}

	void send(T)(string name, in T value)
	{
		// Legacy program uniforms are replaced by explicit bgfx uniforms during submission.
	}

	uint minLen(string name) => 0;
	ubyte flags() => 0;

	void add(ShaderTexture id, Texture tex)
	{
		_texs[id] = tex;
	}

	void add(ShaderBuffer id, VertexBuffer data)
	{
	}

	bgfx_program_handle_t handle() const => _handle;
	bgfx_uniform_handle_t mainTexture() const => _mainTexture;
	const(Texture) mainTextureValue() const => _texs[ShaderTexture.main];

	void submit(IndexVertex iv, uint firstIndex, uint numIndices, in Matrix4 mvp)
	{
		bgfx_set_transform(mvp.ptr, 1);

		if (auto tex = _texs[ShaderTexture.main])
			bgfx_set_texture(0, _mainTexture, tex.handle, tex.samplerFlags);

		auto vertex = iv.vertexBuffer;
		bgfx_set_dynamic_vertex_buffer(0, vertex.vertexHandle, 0, vertex.length / vertex.alignment);
		bgfx_set_dynamic_index_buffer(iv.indexBuffer.indexHandle, firstIndex, numIndices);
		bgfx_set_state(BGFX_STATE_WRITE_RGB_ | BGFX_STATE_WRITE_A_ | BGFX_STATE_WRITE_Z_ | BGFX_STATE_DEPTH_TEST_LESS_, 0);
		bgfx_submit(0, _handle, 0, 0);
	}

private:
	bgfx_program_handle_t _handle;
	bgfx_uniform_handle_t _mainTexture;
	Texture[ShaderTexture.max] _texs;
}
