module perfontain.managers.gui.text;

import
		std.utf,
		std.conv,
		std.array,
		std.regex,
		std.algorithm,

		perfontain;


auto colorSplit(string s, Color c = colorTransparent)
{
	CharColor[] arr;

	void toArr(string s, Color v)
	{
		arr ~= s.map!(a => CharColor(a, v)).array;
	}

	if(c.a)
	{
		toArr(s, c);
	}
	else
	{
		auto re = regex(`(?:\^([\da-f]{6}))?(.*?)(?=\^[\da-f]{6}|$)`, `gis`);

		foreach(m; s.match(re))
		{
			s = m[2];
			c = m[1].length ? Color.fromInt((m[1].to!uint(16) << 8) | 255) : colorBlack;

			toArr(s, c);
		}
	}

	return arr;
}

auto toStaticTexts(CharColor[] arr, Vector2s sz, GUIElement delegate() dg, Font f = null, ubyte flags = 0)
{
	GUIElement[] res;

	if(!f)
	{
		f = PE.fonts.base;
	}

	void add(GUIElement e, CharColor[] arr, ref ushort x)
	{
		auto t = new GUIStaticText(e, arr.map!(a => a.c).array.toUTF8, flags, f);

		t.color = arr[0].col;
		t.pos.x = x;

		x += t.size.x;
	}

	foreach(r; f.toLines(arr, sz.x, sz.y, flags))
	{
		ushort x;
		auto e = dg();

		if(r.length)
		{
			eachGroup!((a, b) => a.col != b.col)(r, (CharColor[] a) => add(e, a, x));
		}

		e.size = Vector2s(sz.x, f.height);
		res ~= e;
	}

	return res;
}
