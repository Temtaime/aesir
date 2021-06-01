module perfontain.vbo;
import std.stdio, std.algorithm, perfontain, perfontain.misc, perfontain.config, perfontain.opengl, perfontain.math.matrix, utile.except;

enum
{
	VBO_DYNAMIC = 1,
}

final class VertexBuffer : RCounted
{
	this(byte type = -1, ubyte flags = 0)
	{
		id = gen!glGenBuffers;

		_type = type;
		_flags = flags;
	}

	~this()
	{
		glDeleteBuffers(1, &id);
	}

	ubyte alignment() const
	{
		return type < 0 ? 4 : _type.vertexSize;
	}

	void update(in void[] data, uint start)
	{
		bind;
		glBufferSubData(typeGL, start, data.length, data.ptr);
	}

	void realloc(in void[] data) => realloc(cast(uint)data.length, data.ptr);

	void realloc(uint len, in void* ptr = null)
	{
		bind;
		glBufferData(typeGL, _length = len, ptr, _flags & VBO_DYNAMIC ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
	}

	void enable()
	{
		bind;

		if (untyped)
			return;

		auto arr = renderLoc[_type];
		ubyte ptr, size = _type.vertexSize;

		foreach (i, v; arr)
		{
			auto r = cast(uint)i;

			glEnableVertexAttribArray(r);
			glVertexAttribPointer(r, v, GL_FLOAT, false, size, cast(void*)ptr);

			ptr += v * 4;
		}
	}

	void bind(ubyte idx) => glBindBufferBase(GL_SHADER_STORAGE_BUFFER, idx, id);

	const uint id;
private:
	void bind()
	{
		glBindBuffer(typeGL, id);
	}

	auto typeGL()
	{
		return untyped ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;
	}

	mixin publicProperty!(byte, `type`);
	mixin publicProperty!(uint, `length`);

	const untyped()
	{
		return _type < 0;
	}

	ubyte _flags;
}
