module perfontain.managers.gui.text;

import std.utf, std.conv, std.array, std.regex, std.algorithm, perfontain;

auto colorSplit(string s, Color c = colorTransparent)
{
	CharColor[] arr;

	void add(string s, Color v)
	{
		arr ~= s.map!(a => CharColor(a, v)).array;
	}

	if (c.a)
	{
		add(s, c);
	}
	else
	{
		auto re = regex(`(?:\^([\da-f]{6}))?(.*?)(?=\^[\da-f]{6}|$)`, `gis`);

		foreach (m; s.match(re))
		{
			s = m[2];
			c = m[1].length ? Color.fromInt((m[1].to!uint(16) << 8) | 255) : colorBlack;

			add(s, c);
		}
	}

	return arr;
}
