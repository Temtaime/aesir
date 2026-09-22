module perfontain.vao;

import perfontain;

final class ArrayBuffer : RCounted
{
	this()
	{
		/* Legacy OpenGL VAO allocation retained until draw submission migrates to bgfx.
		glGenVertexArrays(1, &_id);
		*/
	}

	~this()
	{
		/*
		cas(PEstate._vao, _id, 0);
		glDeleteVertexArrays(1, &_id);
		*/
	}

	void bind()
	{
		/*
		bind(_id);
		*/
	}

	static unbind()
	{
		/*
		bind(0);
		*/
	}

private:
	/*
	static bind(uint v)
	{
		//if (set(PEstate._vao, v))
		{
			glBindVertexArray(v);
		}
	}

	uint _id;
	*/
}
