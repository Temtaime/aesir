module perfontain.rendertarget;

import
		perfontain,
		perfontain.opengl;


final class RenderTarget : RCounted
{
	this(Texture t)
	{
		glCreateFramebuffers(1, &_id);

		glNamedFramebufferTexture(_id, GL_DEPTH_ATTACHMENT, (_tex = t).id, 0);
		glNamedFramebufferDrawBuffer(_id, GL_NONE);

		auto st = glCheckNamedFramebufferStatus(_id, GL_FRAMEBUFFER);
		st == GL_FRAMEBUFFER_COMPLETE_EXT || throwError!`FBO status is 0x%X`(st);
	}

	~this()
	{
		glDeleteFramebuffers(1, &_id);
	}

	void bind()
	{
		glBindFramebuffer(GL_FRAMEBUFFER, _id);
	}

	static unbind()
	{
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	}

	Texture tex() const
	{
		return cast(Texture)_tex;
	}

package:
	uint _id;
	RC!Texture _tex;
}
