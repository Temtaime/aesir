module perfontain.bgfx;

import std.string : fromStringz;
import bindbc.bgfx, perfontain.math.matrix, utile.except, utile.log;

final class BgfxManager
{
	this(void* window, Vector2s size)
	{
		auto init = bgfx.Init(0);
		init.type = bgfx.RendererType.count;
		init.swapChain.nwh = window;
		init.swapChain.width = size.x;
		init.swapChain.height = size.y;
		_swapChain = init.swapChain;

		auto renderers = new bgfx.RendererType[bgfx.RendererType.count];
		auto count = bgfx.getSupportedRenderers(cast(ubyte)renderers.length, renderers.ptr);

		foreach (renderer; renderers[0 .. count])
		{
			logger.info!`supported bgfx renderer: %s (%d)`(
				bgfx.getRendererName(renderer).fromStringz, cast(uint)renderer);
		}

		logger.info!`bgfx requested renderer: %d`(cast(uint)init.type);
		bgfx.init(init) || throwError!`cannot initialize bgfx`();
		_initialized = true;

		auto type = bgfx.getRendererType;
		logger.info!`bgfx renderer: %s (%d), window: 0x%X, swap chain: %ux%u`(
			bgfx.getRendererName(type).fromStringz, cast(uint)type, cast(size_t)window, size.x, size.y);
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
			bgfx.shutdown;
			_initialized = false;
		}
	}

	void resize(Vector2s size)
	{
		_swapChain.width = size.x;
		_swapChain.height = size.y;

		bgfx.reset(bgfx.Reset.none, &_swapChain);
		bgfx.setViewRect(0, 0, 0, size.x, size.y);
	}

	void frame()
	{
		bgfx.setViewClear(0, bgfx.Clear.color | bgfx.Clear.depth, 0xFF00_FFFF);
		bgfx.touch(0);
		bgfx.frame;
	}

private:
	bgfx.SwapChain _swapChain;
	bool _initialized;
}
