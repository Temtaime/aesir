module perfontain.rendertarget;

import perfontain, perfontain.opengl;

final class RenderTarget : RCounted
{
	this(Texture t)
	{
		this();

		_attachments ~= t;

		add(GL_DEPTH_ATTACHMENT, t);

		finish;

		// FIXME gles
		//glFramebufferDrawBuffer(GL_FRAMEBUFFER, GL_NONE);

	}

	this()
	{
		glGenFramebuffers(1, &_id);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);
	}

	void add(uint pos, Texture tex)
	{
		_pos ~= pos;
		_attachments ~= tex;
		glFramebufferTexture2D(GL_FRAMEBUFFER, pos, GL_TEXTURE_2D, tex.id, 0);
	}

	void finish()
	{
		auto st = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		st == GL_FRAMEBUFFER_COMPLETE || throwError!`FBO status is 0x%X`(st);

		unbind;
	}

	~this()
	{
		glDeleteFramebuffers(1, &_id);
	}

	void bind()
	{
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);

		//glDrawBuffers(cast(uint)_pos.length, _pos.ptr);
	}

	static unbind()
	{
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	}

	auto attachments()
	{
		return _attachments[];
	}

package:
	uint _id;

	uint[] _pos;
	RCArray!Texture _attachments;
}
