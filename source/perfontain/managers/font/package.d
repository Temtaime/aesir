module perfontain.managers.font;

import
		std.utf,
		std.conv,
		std.file,
		std.stdio,
		std.ascii,
		std.range,
		std.string,
		std.algorithm,

		stb.image,
		derelict.sdl2.sdl,
		derelict.sdl2.ttf,

		perfontain,
		perfontain.misc.rc;

public import
				perfontain.managers.font.splitter;


enum : ubyte
{
	FONT_BOLD		= 1,
	FONT_OUTLINED	= 2,
	FONT_SOLID		= 4,
}


final:

class FontManager
{
	this()
	{
		TTF_WasInit() || !TTF_Init() || throwSDLTTFError;
	}

	RC!Font
				big,
				base,
				small;
}

class Font : RCounted
{
	this(string name, ubyte size)
	{
		_data = PEfs.get(name);
		_data.length || throwError("can't find file for `%s' font", name);

		{
			auto mem = SDL_RWFromConstMem(_data.ptr, cast(uint)_data.length);

			_font = TTF_OpenFontRW(mem, true, size);
			_font || throwSDLTTFError;
		}

		// make a font looks nicer
		TTF_SetFontHinting(_font, TTF_HINTING_LIGHT);

		// get the height
		height = cast(ushort)TTF_FontHeight(_font);
	}

	~this()
	{
		TTF_CloseFont(_font);
	}

	auto render(string text, ubyte flags = 0)
	{
		assert(text.length);
		setFlags(flags);

		auto f = flags & FONT_SOLID ? &TTF_RenderUTF8_Solid : &TTF_RenderUTF8_Blended;
		auto sur = f(_font, text.toStringz, SDL_Color(255, 255, 255, 0));

		sur || throwSDLTTFError;

		scope(exit)
		{
			SDL_FreeSurface(sur);
		}

		if(sur.format.format != 372645892) // TODO: REPLACE BY NAMED CONSTANT
		{
			auto n = SDL_ConvertSurfaceFormat(sur, 372645892, 0);
			//n || throwSDLError;

			SDL_FreeSurface(sur);
			sur = n;
		}

		return new Image(sur.w, sur.h, sur.pixels[0..sur.w * sur.h * 4].dup);
	}

	uint widthOf(string text, ubyte flags = 0)
	{
		setFlags(flags);

		int w;
		!TTF_SizeUTF8(_font, text.toStringz, &w, null) || throwSDLTTFError;

		assert(render(text, flags).w == w);
		return w;
	}

	auto toLines(string text, short width, short lines = -1, ubyte flags = 0)
	{
		return toLines(text.map!(a => CharColor(a)).array, width, lines, flags).map!(a => a.map!(b => b.c).array.toUTF8).array;
	}

	auto toLines(CharColor[] text, short width, short lines = -1, ubyte flags = 0)
	{
		return LineSplitter(a => widthOf(a, flags), width, lines).split(text);
	}

	const ushort height;
private:
	void setFlags(ubyte flags)
	{
		TTF_SetFontStyle(_font, flags & FONT_BOLD ? TTF_STYLE_BOLD : 0);
		TTF_SetFontOutline(_font, flags & FONT_OUTLINED ? 2 : 0);
	}

	const(ubyte)[] _data;

	TTF_Font *_font;
}

private:

bool throwSDLTTFError(string f = __FILE__, uint l = __LINE__)
{
	return throwError!`SDL TTF error: %s`(f, l, TTF_GetError().fromStringz);
}
