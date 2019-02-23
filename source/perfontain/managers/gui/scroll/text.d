module perfontain.managers.gui.scroll.text;

import
		std.utf,
		std.conv,
		std.regex,
		std.array,
		std.algorithm,

		perfontain;


final class ScrolledText : GUIElement
{
	this(GUIElement p, Vector2s sz)
	{
		super(p, Vector2s(sz.x, font.height * sz.y));

		new Scrolled(this, Vector2s(1, sz.y), font.height);

		sc.size.x = size.x;
		sc.onResize;
	}

	void clear()
	{
		//sc.clear;
	}

	void add(string s, Color c = colorTransparent)
	{
		font
			.toLines(colorSplit(s, c), sc.width)
			.each!(a => add(a));
	}

	bool autoBottom = true;
private:
	mixin MakeChildRef!(Scrolled, `sc`, 0);

	void add(GUIElement e, CharColor[] arr)
	{
		auto t = new GUIStaticText(e, arr.map!(a => a.c).array.toUTF8);

		t.color = arr[0].col;
		t.pos.x = e.size.x;

		e.size.x += t.size.x;
	}

	void add(CharColor[] line)
	{
		auto e = new GUIElement(null);

		if(line.length)
		{
			eachGroup!((a, b) => a.col != b.col)(line, (CharColor[] a) => add(e, a));

			e.size.y = e.childs[0].size.y;
			//e.flags = WIN_CASCADE_SHOW;
		}

		sc.add(e);

		if(autoBottom)
		{
		}
	}

	static font()
	{
		return PE.fonts.base;
	}
}
