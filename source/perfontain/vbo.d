module perfontain.vbo;

import
		std.stdio,
		std.algorithm,

		perfontain,
		perfontain.misc,
		perfontain.config,
		perfontain.opengl,
		perfontain.math.matrix,

		utils.except;


enum
{
	VBO_DYNAMIC		= 1,
}

final class VertexBuffer : RCounted
{
	this(byte type = -1, ubyte flags = 0)
	{
		{
			uint b;
			glCreateBuffers(1, &b);
			id = b;
		}

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
		glNamedBufferSubData(id, start, data.length, data.ptr);
	}

	void realloc(uint len, in void *ptr = null)
	{
		glNamedBufferData(id, _length = len, ptr, _flags & VBO_DYNAMIC ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
	}

	void bind()
	{
		if(untyped)
		{
			return glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
		}

		glBindBuffer(GL_ARRAY_BUFFER, id);

		ubyte	ptr,
				size = _type.vertexSize;

		auto arr = renderLoc[_type];

		foreach(i, v; arr)
		{
			auto r = cast(uint)i;

			glEnableVertexAttribArray(r);
			glVertexAttribPointer(r, v, GL_FLOAT, false, size, cast(void*)ptr);

			ptr += v * 4;
		}
	}

	const uint id;
private:
	mixin publicProperty!(byte, `type`);
	mixin publicProperty!(uint, `length`);

	const untyped()
	{
		return _type < 0;
	}

	ubyte _flags;
}
