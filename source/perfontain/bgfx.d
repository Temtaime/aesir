module perfontain.bgfx;

import std.string : fromStringz;
import bgfx_c, perfontain.math.matrix, perfontain.render.types, utile.except, utile.log;

final class BgfxManager
{
	this(void* window, Vector2s size)
	{
		bgfx_init_t init;
		bgfx_init_ctor(&init);
		init.type = BGFX_RENDERER_TYPE_COUNT;
		init.swapChain.nwh = window;
		init.swapChain.width = size.x;
		init.swapChain.height = size.y;
		_swapChain = init.swapChain;

		with (_layouts[RENDER_GUI])
		{
			bgfx_vertex_layout_begin(&_layouts[RENDER_GUI], BGFX_RENDERER_TYPE_COUNT);
			bgfx_vertex_layout_add(&_layouts[RENDER_GUI], BGFX_ATTRIB_POSITION, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false);
			bgfx_vertex_layout_add(&_layouts[RENDER_GUI], BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false);
			bgfx_vertex_layout_end(&_layouts[RENDER_GUI]);
		}

		with (_layouts[RENDER_SCENE])
		{
			bgfx_vertex_layout_begin(&_layouts[RENDER_SCENE], BGFX_RENDERER_TYPE_COUNT);
			bgfx_vertex_layout_add(&_layouts[RENDER_SCENE], BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false);
			bgfx_vertex_layout_add(&_layouts[RENDER_SCENE], BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false);
			bgfx_vertex_layout_add(&_layouts[RENDER_SCENE], BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false);
			bgfx_vertex_layout_end(&_layouts[RENDER_SCENE]);
		}

		auto renderers = new bgfx_renderer_type_t[BGFX_RENDERER_TYPE_COUNT];
		auto count = bgfx_get_supported_renderers(cast(ubyte)renderers.length, renderers.ptr);

		foreach (renderer; renderers[0 .. count])
		{
			logger.info!`supported bgfx renderer: %s (%d)`(
				bgfx_get_renderer_name(renderer).fromStringz, cast(uint)renderer);
		}

		logger.info!`bgfx requested renderer: %d`(cast(uint)init.type);
		bgfx_init(&init) || throwError!`cannot initialize bgfx`();
		_initialized = true;

		auto type = bgfx_get_renderer_type();
		logger.info!`bgfx renderer: %s (%d), window: 0x%X, swap chain: %ux%u`(
			bgfx_get_renderer_name(type).fromStringz, cast(uint)type, cast(size_t)window, size.x, size.y);
		resize(size);
	}

	~this()
	{
		shutdown;
	}

	void shutdown()
	{
		if (_initialized)
		{
			bgfx_shutdown();
			_initialized = false;
		}
	}

	void resize(Vector2s size)
	{
		_swapChain.width = size.x;
		_swapChain.height = size.y;

		bgfx_reset(BGFX_RESET_NONE_, &_swapChain);
		bgfx_set_view_rect(0, 0, 0, size.x, size.y, 0, 1);
	}

	void frame()
	{
		bgfx_set_view_clear(0, BGFX_CLEAR_COLOR_ | BGFX_CLEAR_DEPTH_, 0xFF00_FFFF, 1, 0);
		bgfx_touch(0);
		bgfx_frame(BGFX_FRAME_NONE_);
	}

	ref bgfx_vertex_layout_t layout(ubyte type)
	{
		return _layouts[type];
	}

private:
	bgfx_swap_chain_t _swapChain;
	bgfx_vertex_layout_t[2] _layouts;
	bool _initialized;
}
