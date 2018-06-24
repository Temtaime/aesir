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

		stb.image,

		perfontain,
		perfontain.misc,
		perfontain.opengl,
		perfontain.shader.lang,
		perfontain.shader.types,

		utils.except;


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

			status || throwError!"shader `%s' failed to compile:\n%s"(name, compileLog);
		}
	}

	~this()
	{
		glDeleteShader(id);
	}

	const
	{
		uint id;
		ubyte type;
	}

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
