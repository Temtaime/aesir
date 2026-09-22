module perfontain.rendertarget;
import bgfx_c, std, perfontain;

final class RenderTarget : RCounted
{
	this(Texture depth, Texture[] color)
	in
	{
		assert(depth || color);
	}
	do
	{
		if (depth)
		{
			_attachments ~= depth;
			_clearFlags |= BGFX_CLEAR_DEPTH_;
		}

		if (color)
		{
			uint[] arr;

			_attachments ~= color;
			_clearFlags |= BGFX_CLEAR_COLOR_;
		}

		_size = _attachments[0].size;
		assert(_attachments[1 .. $].all!(a => a.size == _size));

		auto handles = color.map!(a => a.handle).array;
		if (depth)
			handles ~= depth.handle;

		_frameBuffer = bgfx_create_frame_buffer_from_handles(cast(ubyte)handles.length, handles.ptr, false);
	}

	~this() => bgfx_destroy_frame_buffer(_frameBuffer);

	void bind()
	{
		/* Legacy OpenGL framebuffer bind retained until scene views migrate to bgfx.
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _id);
		*/
	}

	static unbind()
	{
		/*
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
		*/
	}

	auto attachments() => _attachments[];
package:
	mixin publicProperty!(Vector2s, `size`);
	mixin publicProperty!(ushort, `clearFlags`);

	const(bgfx_frame_buffer_handle_t) frameBuffer() => _frameBuffer;

	bgfx_frame_buffer_handle_t _frameBuffer;
	RCArray!Texture _attachments;
}
