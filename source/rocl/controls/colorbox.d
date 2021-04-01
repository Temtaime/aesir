module rocl.controls.colorbox;
import std, perfontain, perfontain : Group;

struct ColorBox
{
	void draw()
	{
		if (auto group = Group(nk, nk.uniqueId))
		{
			//auto s1 = Style(&ctx.style.window.spacing, nk_vec2(0, 0));

			nk.layout_row_dynamic(0, 1);
			auto w = cast(ushort)nk.widget_size().x;

			if (_width != w)
			{
				_width = w;
				_cache = _messages.map!(a => makeLines(a)).join;
			}

			_cache.each!(a => nk.coloredText(a));
		}
	}

	void add(string s, Color c)
	{
		_messages ~= colorSplit(s, c);

		if (_width)
			_cache ~= makeLines(_messages.back);
	}

private:
	mixin Nuklear;

	auto makeLines(CharColor[] line)
	{
		return StringSplitter(a => nk.widthFor(a)).split(line, _width);
	}

	ushort _width;
	CharColor[][] _cache, _messages;
}
