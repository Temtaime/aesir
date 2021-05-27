module perfontain.rendertarget;
import std, perfontain, perfontain.opengl;

final class RenderTarget : RCounted
{
	this(Texture depth, Texture[] color)
	{
		glGenFramebuffers(1, &_id);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);

		if (depth)
		{
			_attachments ~= depth;
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth.id, 0);
		}

		if (color)
		{
			uint[] arr;
			_attachments ~= color;

			foreach (i, tex; color)
			{
				arr ~= GL_COLOR_ATTACHMENT0 + cast(uint)i;
				glFramebufferTexture2D(GL_FRAMEBUFFER, arr.back, GL_TEXTURE_2D, tex.id, 0);
			}

			glDrawBuffers(cast(uint)arr.length, arr.ptr);
		}

		assert(_attachments.length);

		_size = _attachments[0].size;
		assert(_attachments[1 .. $][].all!(a => a.size == _size));

		check;
		unbind;
	}

	~this()
	{
		glDeleteFramebuffers(1, &_id);
	}

	void bind() => glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);
	static unbind() => glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);

	auto attachments() => _attachments[];
package:
	mixin publicProperty!(Vector2s, `size`);

	void check()
	{
		auto st = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		st == GL_FRAMEBUFFER_COMPLETE || throwError!`FBO status is 0x%X`(st);
	}

	uint _id;
	RCArray!Texture _attachments;
}
