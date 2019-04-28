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

	void add(string s, Color v)
	{
		arr ~= s.map!(a => CharColor(a, v)).array;
	}

	if(c.a)
	{
		add(s, c);
	}
	else
	{
		auto re = regex(`(?:\^([\da-f]{6}))?(.*?)(?=\^[\da-f]{6}|$)`, `gis`);

		foreach(m; s.match(re))
		{
			s = m[2];
			c = m[1].length ? Color.fromInt((m[1].to!uint(16) << 8) | 255) : colorBlack;

			add(s, c);
		}
	}

	return arr;
}

auto toStaticTexts(string s, short height, Color c = colorTransparent, FontInfo fi = FontInfo.init)
{
	return toStaticTexts(colorSplit(s, c), height, fi);
}

auto toStaticTexts(CharColor[] arr, short height, FontInfo fi = FontInfo.init)
{
	Vector2s pos;
	GUIStaticText[][] res;

	void add(CharColor[] arr) // TODO: SCROLLED TEXT
	{
		auto t = new GUIStaticText(null, arr.map!(a => a.c).array.toUTF8);
		t.pos = pos;
		t.color = arr[0].color;

		res.back ~= t;
		pos.x += t.size.x;
	}

	auto f = fi.font ? fi.font : PE.fonts.base;

	foreach(r; f.toLines(arr, fi.maxWidth, height, fi.flags))
	{
		res.length++;

		if(r.length)
		{
			eachGroup!((a, b) => a.color != b.color)(r, &add);
			pos.x = 0;
		}

		pos.y += f.height;
	}

	return res;
}
