module perfontain.vbo;
import bgfx_c, std.stdio, std.algorithm, perfontain, perfontain.misc, perfontain.config, perfontain.opengl, perfontain.math.matrix, utile.except;

enum
{
	VBO_DYNAMIC = 1,
}

final class VertexBuffer : RCounted
{
	this(byte type = -1, ubyte flags = 0)
	{
		_type = type;
		_flags = flags;

		/* Legacy OpenGL buffer allocation retained until the bgfx migration is complete.
		id = gen!glGenBuffers;
		*/
	}

	~this()
	{
		if (_created)
		{
			if (untyped)
				bgfx_destroy_dynamic_index_buffer(_index);
			else
				bgfx_destroy_dynamic_vertex_buffer(_vertex);
		}

		/*
		glDeleteBuffers(1, &id);
		*/
	}

	ubyte alignment() const
	{
		return type < 0 ? 4 : _type.vertexSize;
	}

	void update(in void[] data, uint start)
	{
		assert(_created);

		auto mem = bgfx_copy(data.ptr, cast(uint)data.length);

		if (untyped)
			bgfx_update_dynamic_index_buffer(_index, start / 4, mem);
		else
			bgfx_update_dynamic_vertex_buffer(_vertex, start / alignment, mem);

		/*
		bind;
		glBufferSubData(typeGL, start, data.length, data.ptr);
		*/
	}

	void realloc(in void[] data) => realloc(cast(uint)data.length, data.ptr);

	void realloc(uint len, in void* ptr = null)
	{
		if (_created)
		{
			if (untyped)
				bgfx_destroy_dynamic_index_buffer(_index);
			else
				bgfx_destroy_dynamic_vertex_buffer(_vertex);
		}

		_length = len;
		_created = true;

		if (untyped)
		{
			_index = bgfx_create_dynamic_index_buffer(len / 4, BGFX_BUFFER_INDEX32_ | BGFX_BUFFER_ALLOW_RESIZE_);
		}
		else
		{
			_vertex = bgfx_create_dynamic_vertex_buffer(len / alignment, &PE.bgfx.layout(cast(ubyte)_type), BGFX_BUFFER_ALLOW_RESIZE_);
		}

		if (ptr)
			update(ptr[0 .. len], 0);

		/*
		bind;
		glBufferData(typeGL, _length = len, ptr, _flags & VBO_DYNAMIC ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
		*/
	}

	void enable()
	{
		/* Legacy VAO attribute setup retained until draw submission migrates to bgfx.
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
		*/
	}

	void bind(ubyte idx)
	{
		/*
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, idx, id);
		*/
	}

private:
	mixin publicProperty!(byte, `type`);
	mixin publicProperty!(uint, `length`);

	const untyped()
	{
		return _type < 0;
	}

	ubyte _flags;
	bool _created;
	bgfx_dynamic_index_buffer_handle_t _index;
	bgfx_dynamic_vertex_buffer_handle_t _vertex;
}
