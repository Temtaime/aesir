module perfontain.managers.window;
import std, perfontain.misc, perfontain, perfontain.math.matrix, perfontain.opengl, utile.except, nuklear;
public import derelict.sdl2.sdl;

enum : ubyte
{
	MOUSE_LEFT = 1,
	MOUSE_MIDDLE = 2,
	MOUSE_RIGHT = 4,
}

final:

class WindowManager
{
	void create(string title, string backend)
	{
		environment[`ANGLE_DEFAULT_PLATFORM`] = backend;

		{
			string suffix;
			debug suffix = `_debug`;

			const path = buildPath(thisExePath.dirName, ANGLE_DIR ~ suffix);

			version (Windows)
			{
				const ext = `dll`;
			}
			else
			{
				const ext = `so`;
			}

			environment[`SDL_VIDEO_GL_DRIVER`] = buildPath(path, `libGLESv2`.setExtension(ext));
			environment[`SDL_VIDEO_EGL_DRIVER`] = buildPath(path, `libEGL`.setExtension(ext));
		}

		SDL_Init(SDL_INIT_VIDEO) && throwSDLError;

		{
			SDL_DisplayMode mode;
			SDL_GetDesktopDisplayMode(0, &mode) && throwSDLError;

			_size = Vector2s(mode.w, mode.h);
			_size -= Vector2s(100, 90);
		}

		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1) && throwSDLError;

		// if (PE.settings.msaa)
		// {
		// 	!SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1) || throwSDLError;
		// 	!SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, MSAA_LEVEL) || throwSDLError;
		// }

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, OPENGL_VERSION / 10) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, OPENGL_VERSION % 10) && throwSDLError;
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES) && throwSDLError;

		{
			auto f = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;

			if (PE.settings.fullscreen)
			{
				f |= SDL_WINDOW_FULLSCREEN_DESKTOP;
			}

			_win = SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _size.x, _size.y, f);
			_win || throwSDLError;
		}

		_ctx = SDL_GL_CreateContext(_win);
		hookGL;

		SDL_GL_SetSwapInterval(0);
		//SDL_GL_SetSwapInterval(1);

		//SDL_StopTextInput();
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

	auto ctx()
	{
		return PE.gui.ctx.ctx;
	}

	auto isGuiHovered()
	{
		for (auto w = ctx.begin; w; w = w.next)
		{
			if (w.flags & NK_WINDOW_NOT_INTERACTIVE)
				continue;

			//logger(*w);

			if (nk_input_is_mouse_hovering_rect(&ctx.input, w.bounds))
				return true;
		}

		return false;
		//return !!nk_item_is_any_active(ctx);

		//return !!nk_window_is_any_hovered(ctx);
	}

	void processEvents()
	{
		auto inGui = isGuiHovered();

		nk_input_begin(ctx);

		loop: for (SDL_Event evt; SDL_PollEvent(&evt);) switch (evt.type)
		{
			/*case SDL_MOUSEWHEEL:
				auto sc = Vector2s(evt.wheel.x, evt.wheel.y);

				if(evt.wheel.direction == SDL_MOUSEWHEEL_FLIPPED)
				{
					sc[][] *= -1;
				}

				PE.onWheel.first(sc);
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

				break;*/
		case SDL_WINDOWEVENT:
			switch (evt.window.event)
			{
			case SDL_WINDOWEVENT_FOCUS_GAINED:
				//_active = _skip = true;
				break;

			case SDL_WINDOWEVENT_FOCUS_LOST:
				//_active = false;
				break;

			case SDL_WINDOWEVENT_SIZE_CHANGED:
				PE.onResize(_size = Vector2s(evt.window.data1, evt.window.data2));
				break;

			default:
			}

			goto default;

		case SDL_KEYUP:
		case SDL_KEYDOWN:
			auto r = evt.key.keysym.sym;

			if (!evt.key.repeat)
			{
				auto st = evt.key.state == SDL_PRESSED;

				if (st)
				{
					_keys ~= r;
				}
				else
				{
					_keys = _keys.remove(_keys.countUntil(r));
				}

				PE.onKey.last(r, st);
			}

			goto default;

		case SDL_MOUSEBUTTONUP:
		case SDL_MOUSEBUTTONDOWN:
			const map = [SDL_BUTTON_LEFT : MOUSE_LEFT, SDL_BUTTON_MIDDLE:
				MOUSE_MIDDLE, SDL_BUTTON_RIGHT:
				MOUSE_RIGHT];

			auto t = map[cast(SDL_D_MouseButton)evt.button.button]; // TODO: REPORT DERELICT
			auto v = evt.button.state == SDL_PRESSED;

			//if(inGui && !(_mouse & t))
			//		goto default;

			if (!inGui || (_mouse & t))
			{
				byFlag(_mouse, t, v);
				PE.onButton.first(t, v);
			}

			/*if(!v && evt.button.clicks == 2)
				{
					PE.onDoubleClick.first(t);
				}*/

			goto default;

		case SDL_MOUSEMOTION:
			if (_skip)
			{
				_skip = false;
			}
			else
			{
				PE.onMoveDelta(Vector2s(evt.motion.xrel, evt.motion.yrel));
			}

			PE.onMove.reverse(Vector2s(evt.motion.x, evt.motion.y));
			goto default;

		case SDL_QUIT:
			PE._run = false;
			break loop;

		default:
			nk_sdl_handle_event(&evt);
		}

		nk_input_end(ctx);
	}

private:
	mixin publicProperty!(uint[], `keys`);

	void onVSync(bool v)
	{
		//if(!v || SDL_GL_SetSwapInterval(-1))
		{
			//!SDL_GL_SetSwapInterval(v) || throwSDLError;
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

	SDL_Window* _win;
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

int nk_sdl_handle_event(SDL_Event* evt)
{
	nk_context* ctx = PE.gui.ctx.ctx;

	if (evt.type == SDL_KEYUP || evt.type == SDL_KEYDOWN)
	{
		/* key events */
		bool down = evt.type == SDL_KEYDOWN;
		const Uint8* state = SDL_GetKeyboardState(null);
		SDL_Keycode sym = evt.key.keysym.sym;
		if (sym == SDLK_RSHIFT || sym == SDLK_LSHIFT)
			nk_input_key(ctx, NK_KEY_SHIFT, down);
		else if (sym == SDLK_DELETE)
			nk_input_key(ctx, NK_KEY_DEL, down);
		else if (sym == SDLK_RETURN)
			nk_input_key(ctx, NK_KEY_ENTER, down);
		else if (sym == SDLK_TAB)
			nk_input_key(ctx, NK_KEY_TAB, down);
		else if (sym == SDLK_BACKSPACE)
			nk_input_key(ctx, NK_KEY_BACKSPACE, down);
		else if (sym == SDLK_HOME)
		{
			nk_input_key(ctx, NK_KEY_TEXT_START, down);
			nk_input_key(ctx, NK_KEY_SCROLL_START, down);
		}
		else if (sym == SDLK_END)
		{
			nk_input_key(ctx, NK_KEY_TEXT_END, down);
			nk_input_key(ctx, NK_KEY_SCROLL_END, down);
		}
		else if (sym == SDLK_PAGEDOWN)
		{
			nk_input_key(ctx, NK_KEY_SCROLL_DOWN, down);
		}
		else if (sym == SDLK_PAGEUP)
		{
			nk_input_key(ctx, NK_KEY_SCROLL_UP, down);
		}
		else if (sym == SDLK_z)
			nk_input_key(ctx, NK_KEY_TEXT_UNDO, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_r)
			nk_input_key(ctx, NK_KEY_TEXT_REDO, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_c)
			nk_input_key(ctx, NK_KEY_COPY, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_v)
			nk_input_key(ctx, NK_KEY_PASTE, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_x)
			nk_input_key(ctx, NK_KEY_CUT, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_b)
			nk_input_key(ctx, NK_KEY_TEXT_LINE_START, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_e)
			nk_input_key(ctx, NK_KEY_TEXT_LINE_END, down && state[SDL_SCANCODE_LCTRL]);
		else if (sym == SDLK_UP)
			nk_input_key(ctx, NK_KEY_UP, down);
		else if (sym == SDLK_DOWN)
			nk_input_key(ctx, NK_KEY_DOWN, down);
		else if (sym == SDLK_LEFT)
		{
			if (state[SDL_SCANCODE_LCTRL])
				nk_input_key(ctx, NK_KEY_TEXT_WORD_LEFT, down);
			else
				nk_input_key(ctx, NK_KEY_LEFT, down);
		}
		else if (sym == SDLK_RIGHT)
		{
			if (state[SDL_SCANCODE_LCTRL])
				nk_input_key(ctx, NK_KEY_TEXT_WORD_RIGHT, down);
			else
				nk_input_key(ctx, NK_KEY_RIGHT, down);
		}
		else
			return 0;
		return 1;
	}
	else if (evt.type == SDL_MOUSEBUTTONDOWN || evt.type == SDL_MOUSEBUTTONUP)
	{
		/* mouse button */
		bool down = evt.type == SDL_MOUSEBUTTONDOWN;
		const int x = evt.button.x, y = evt.button.y;
		if (evt.button.button == SDL_BUTTON_LEFT)
		{
			if (evt.button.clicks > 1)
				nk_input_button(ctx, NK_BUTTON_DOUBLE, x, y, down);
			nk_input_button(ctx, NK_BUTTON_LEFT, x, y, down);
		}
		else if (evt.button.button == SDL_BUTTON_MIDDLE)
			nk_input_button(ctx, NK_BUTTON_MIDDLE, x, y, down);
		else if (evt.button.button == SDL_BUTTON_RIGHT)
			nk_input_button(ctx, NK_BUTTON_RIGHT, x, y, down);
		return 1;
	}
	else if (evt.type == SDL_MOUSEMOTION)
	{
		/* mouse motion */
		if (ctx.input.mouse.grabbed)
		{
			int x = cast(int)ctx.input.mouse.prev.x, y = cast(int)ctx.input.mouse.prev.y;
			nk_input_motion(ctx, x + evt.motion.xrel, y + evt.motion.yrel);
		}
		else
			nk_input_motion(ctx, evt.motion.x, evt.motion.y);
		return 1;
	}
	else if (evt.type == SDL_TEXTINPUT)
	{
		/* text input */
		nk_glyph glyph;
		import core.stdc.string;

		memcpy(glyph.ptr, evt.text.text.ptr, NK_UTF_SIZE);
		nk_input_glyph(ctx, glyph.ptr);
		return 1;
	}
	else if (evt.type == SDL_MOUSEWHEEL)
	{
		/* mouse wheel */
		nk_input_scroll(ctx, nk_vec2(cast(float)evt.wheel.x, cast(float)evt.wheel.y));
		return 1;
	}
	return 0;
}
