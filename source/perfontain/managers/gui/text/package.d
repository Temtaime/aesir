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

auto toStaticTexts(string s, Vector2s sz, Color c = colorTransparent, Font f = null, ubyte flags = 0)
{
	return toStaticTexts(colorSplit(s, c), sz, f, flags);
}

auto toStaticTexts(CharColor[] arr, Vector2s sz, Font f = null, ubyte flags = 0)
{
	if(!f)
	{
		f = PE.fonts.base;
	}

	Vector2s pos;
	GUIStaticText[][] res;

	void add(CharColor[] arr)
	{
		auto t = new GUIStaticText(null, arr.map!(a => a.c).array.toUTF8, flags, f);

		t.pos = pos;
		t.color = arr[0].col;

		res.back ~= t;
		pos.x += t.size.x;
	}

	foreach(r; f.toLines(arr, sz.x, sz.y, flags))
	{
		res.length++;

		if(r.length)
		{
			eachGroup!((a, b) => a.col != b.col)(r, &add);
			pos.x = 0;
		}

		pos.y += f.height;
	}

	return res;
}
