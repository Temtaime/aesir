module perfontain.vao;

import perfontain, perfontain.opengl;

final class ArrayBuffer : RCounted
{
	this()
	{
		glGenVertexArrays(1, &_id);
	}

	~this()
	{
		cas(PEstate._vao, _id, 0);
		glDeleteVertexArrays(1, &_id);
	}

	void bind()
	{
		bind(_id);
	}

	static unbind()
	{
		bind(0);
	}

private:
	static bind(uint v)
	{
		//if (set(PEstate._vao, v))
		{
			glBindVertexArray(v);
		}
	}

	uint _id;
}
