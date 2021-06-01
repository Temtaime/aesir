module perfontain.rendertarget;
import std, perfontain, perfontain.opengl;

final class RenderTarget : RCounted
{
	this(Texture depth, Texture[] color)
	in
	{
		assert(depth || color);
	}
	do
	{
		_id = gen!glGenFramebuffers;
		bind;

		if (depth)
		{
			_attachments ~= depth;
			_clearFlags |= GL_DEPTH_BUFFER_BIT;

			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth.id, 0);
		}

		if (color)
		{
			uint[] arr;

			_attachments ~= color;
			_clearFlags |= GL_COLOR_BUFFER_BIT;

			foreach (i, tex; color)
			{
				arr ~= GL_COLOR_ATTACHMENT0 + cast(uint)i;

				glFramebufferTexture2D(GL_FRAMEBUFFER, arr.back, GL_TEXTURE_2D, tex.id, 0);
			}

			glDrawBuffers(cast(uint)arr.length, arr.ptr);
		}

		_size = _attachments[0].size;
		assert(_attachments[1 .. $].all!(a => a.size == _size));

		check;
		unbind;
	}

	~this() => glDeleteFramebuffers(1,  & _id);

	void bind() => glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);
	static unbind() => glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);

	auto attachments() => _attachments[];
package:
	mixin publicProperty!(Vector2s, `size`);
	mixin publicProperty!(uint, `clearFlags`);

	void check()
	{
		auto st = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		st == GL_FRAMEBUFFER_COMPLETE || throwError!`FBO status is 0x%X`(st);
	}

	const uint _id;
	RCArray!Texture _attachments;
}
