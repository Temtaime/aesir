module perfontain.shader;

import
		std.file,
		std.conv,
		std.stdio,
		std.range,
		std.traits,
		std.string,
		std.typecons,
		std.exception,
		std.algorithm,

		stb.wrapper.image,

		perfontain,
		perfontain.misc,
		perfontain.opengl,
		perfontain.shader.lang,
		perfontain.shader.types,

		tt.error;


struct Attrib
{
	uint	type,
			size;
}

final class Shader : RCounted
{
	this(string name, string data, ubyte t)
	{
		auto tp = shaderTypes[type = t];
		auto p = data.toStringz;

		id = glCreateShader(tp);

		glShaderSource(id, 1, &p, null);
		glCompileShader(id);

		{
			int status;
			glGetShaderiv(id, GL_COMPILE_STATUS, &status);

			status || throwError("shader `%s' failed to compile:\n%s", name, compileLog);
		}
	}

	~this()
	{
		glDeleteShader(id);
	}

	void parseAttribs()
	{
		int cnt, nameLen;

		enum Attribs =
		[
			tuple(GL_ACTIVE_UNIFORMS, GL_ACTIVE_UNIFORM_MAX_LENGTH, `glGetActiveUniform`),
			tuple(GL_ACTIVE_ATTRIBUTES, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, `glGetActiveAttrib`),
		];

		static foreach(e; Attribs)
		{
			glGetProgramiv(id, e[0], &cnt);
			glGetProgramiv(id, e[1], &nameLen);

			foreach(i; 0..cnt)
			{
				int size;
				uint len, type;

				auto name = new char[nameLen];
				mixin(e[2] ~ `(id, i, cast(uint)name.length, &len, &size, &type, name.ptr);`);

				attribs[name[0..len].idup] = Attrib(type, size);
			}
		}
	}

	const
	{
		uint id;
		ubyte type;
	}

	Attrib[string] attribs;
private:
	auto compileLog()
	{
		int len;
		glGetShaderiv(id, GL_INFO_LOG_LENGTH, &len);

		assert(len);
		auto str = new char[len];

		glGetShaderInfoLog(id, len, null, str.ptr);
		return str[0..$ - 1].assumeUnique;
	}
}
