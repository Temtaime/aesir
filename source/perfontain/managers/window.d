module perfontain.managers.window;

import
		std,

		perfontain.misc,
		perfontain,
		perfontain.math.matrix,
		perfontain.opengl,

		utils.except;

public import
				derelict.sdl2.sdl;


enum : ubyte
{
	MOUSE_LEFT		= 1,
	MOUSE_MIDDLE	= 2,
	MOUSE_RIGHT		= 4,
}

final:

class WindowManager
{
	void create(string title)
	{
		!SDL_Init(SDL_INIT_VIDEO) || throwSDLError;
		!SDL_GL_LoadLibrary(null) || throwSDLError;

		{
			SDL_DisplayMode mode;
			!SDL_GetDesktopDisplayMode(0, &mode) || throwSDLError;

			_size = Vector2s(mode.w, mode.h);
		}

		_size -= Vector2s(100, 90);

		debug
		{
			if(_size.x > 1920)
			{
				_size = Vector2s(1920, 1080);
			}
		}

		!SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24) || throwSDLError;

		if(PE.settings.msaa)
		{
			!SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1) || throwSDLError;
			!SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, MSAA_LEVEL) || throwSDLError;
		}

		!SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, OPENGL_VERSION / 10) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, OPENGL_VERSION % 10) || throwSDLError;
		!SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE) || throwSDLError;

		{
			auto flags = SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG;

			debug
			{
				flags |= SDL_GL_CONTEXT_DEBUG_FLAG;
			}

			!SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, flags) || throwSDLError;
		}

		{
			auto f = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;

			if(PE.settings.fullscreen)
			{
				f |= SDL_WINDOW_FULLSCREEN_DESKTOP;
			}

			_win = SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _size.x, _size.y, f);
			_win || throwSDLError;
		}

		_ctx = SDL_GL_CreateContext(_win);
		_ctx || throwSDLError;

		{
			int v;
			!SDL_GL_GetAttribute(SDL_GL_MULTISAMPLESAMPLES, &v) || throwSDLError;

			PE._msaaLevel = v > 1 ? cast(ubyte)v : 0;
		}

		SDL_StopTextInput();
		SDL_SetWindowMinimumSize(_win, 640, 480);

		onVSync(PE.settings.vsync);

		PE.settings.vsyncChange.permanent(&onVSync);
		PE.settings.fullscreenChange.permanent(&onFS);
	}

	~this()
	{
		SDL_GL_DeleteContext(_ctx);
		SDL_DestroyWindow(_win);
		SDL_GL_UnloadLibrary();
		SDL_Quit();
	}

	@property cursor(bool v)
	{
		//!SDL_SetRelativeMouseMode(!v) || throwSDLError;
	}

	@property title(string s)
	{
		SDL_SetWindowTitle(_win, s.toStringz);
	}

	@property left()
	{
		return !!(_mouse & MOUSE_LEFT);
	}

	@property right()
	{
		return !!(_mouse & MOUSE_RIGHT);
	}

	@property middle()
	{
		return !!(_mouse & MOUSE_MIDDLE);
	}

	@property mpos()
	{
		int x, y;
		SDL_GetMouseState(&x, &y);
		return Vector2s(x, y);
	}

package(perfontain):

	mixin publicProperty!(Vector2s, `size`);

	mixin publicProperty!(bool, `active`);
	mixin publicProperty!(ubyte, `mouse`);

	void swapBuffers()
	{
		SDL_GL_SwapWindow(_win);
	}

	void processEvents()
	{
		SDL_Event evt;

		while(SDL_PollEvent(&evt))
		{
			switch(evt.type)
			{
			case SDL_MOUSEWHEEL:
				auto sc = Vector2s(evt.wheel.x, evt.wheel.y);

				if(evt.wheel.direction == SDL_MOUSEWHEEL_FLIPPED)
				{
					sc[][] *= -1;
				}

				PE.onWheel.first(sc);
				break;

			case SDL_KEYUP:
			case SDL_KEYDOWN:
				auto r = evt.key.keysym.sym;

				if(!evt.key.repeat || r == SDLK_BACKSPACE)
				{
					auto st = evt.key.state == SDL_PRESSED;

					if(st)
					{
						_keys ~= r;
					}
					else
					{
						_keys = _keys.remove(_keys.countUntil(r));
					}

					PE.onKey.last(r, st);
				}

				break;

			case SDL_WINDOWEVENT:
				switch(evt.window.event)
				{
				case SDL_WINDOWEVENT_FOCUS_GAINED:
					_active = _skip = true;
					break;

				case SDL_WINDOWEVENT_FOCUS_LOST:
					_active = false;
					break;

				case SDL_WINDOWEVENT_RESIZED:
					PE.onResize(_size = Vector2s(evt.window.data1, evt.window.data2));
					break;

				default:
				}

				break;

			case SDL_MOUSEBUTTONUP:
			case SDL_MOUSEBUTTONDOWN:
				const map =
				[
					SDL_BUTTON_LEFT: MOUSE_LEFT,
					SDL_BUTTON_MIDDLE: MOUSE_MIDDLE,
					SDL_BUTTON_RIGHT: MOUSE_RIGHT
				];

				auto t = map[cast(SDL_D_MouseButton)evt.button.button]; // TODO: REPORT DERELICT
				auto b = evt.button.state == SDL_PRESSED;

				if(!b && evt.button.clicks == 2)
				{
					PE.onDoubleClick.first(t);
				}

				byFlag(_mouse, t, b);
				PE.onButton.first(t, b);

				break;

			case SDL_MOUSEMOTION:
				if(_skip)
				{
					_skip = false;
				}
				else
				{
					PE.onMoveDelta(Vector2s(evt.motion.xrel, evt.motion.yrel));
				}

				PE.onMove.reverse(Vector2s(evt.motion.x, evt.motion.y));
				break;

			case SDL_TEXTINPUT:
				if(_text)
				{
					_text(evt.text.text.ptr.fromStringz.idup);
				}

				break;

			case SDL_QUIT:
				PE._run = false;
				break;

			default:
			}
		}
	}

private:
	mixin publicProperty!(uint[], `keys`);

	void onVSync(bool v)
	{
		//if(!v || SDL_GL_SetSwapInterval(-1))
		{
			!SDL_GL_SetSwapInterval(v) || throwSDLError;
		}
	}

	void onFS(bool b)
	{
		!SDL_SetWindowFullscreen(_win, b ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0) || throwSDLError;
	}

	bool throwSDLError(string f = __FILE__, uint l = __LINE__)
	{
		return throwError(SDL_GetError().fromStringz, f, l);
	}

	SDL_Window *_win;
	SDL_GLContext _ctx;

	void delegate(string) _text;
	bool _skip;
	ubyte _flags;
}

class TextInput : RCounted
{
	this(void delegate(string) f)
	{
		assert(!SDL_IsTextInputActive());

		SDL_StartTextInput();
		PEwindow._text = f;
	}

	~this()
	{
		SDL_StopTextInput();
		PEwindow._text = null;
	}
}

void showErrorMessage(string s)
{
	SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, `Error`, s.toStringz, null);
}
