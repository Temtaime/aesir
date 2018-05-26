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
	this(GUIElement p, Vector2s sz, ushort id)
	{
		super(p);

		size = new Scrolled(this, Vector2s(sz.x, PE.fonts.base.height), sz.y, id).size;
	}

	void clear()
	{
		sc.clear;
	}

	void add(string s, Color c = colorTransparent)
	{
		PE.fonts.base.toLines(colorSplit(s, c), sc.container.size.x).each!(a => add(a));
	}

	bool autoBottom = true;
private:
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

		sc.add(e, true, autoBottom);
	}

	inout sc()
	{
		return cast(Scrolled)childs[0];
	}
}
