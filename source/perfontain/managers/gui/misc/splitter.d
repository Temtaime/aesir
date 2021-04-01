module perfontain.managers.gui.misc.splitter;
import std, perfontain, std.digest.crc, perfontain.managers.gui.misc, std.uni : isWhite;

struct StringSplitter
{
	this(ushort delegate(string) calcWidth)
	{
		_calcWidth = calcWidth;
	}

	auto split(CharColor[] s, ushort width)
	{
		CharColor[][] res;

		for (skipWhitespaces(s); s.length; skipWhitespaces(s))
		{
			uint p;

			do
			{
				auto next = p;

				while (s[next].c.isWhite) // skip whitespaces between words
					next++;
				while (next != s.length && !s[next].c.isWhite) // iterate until end of the word
					next++;

				if (calcWidth(s[0 .. next]) > width)
				{
					if (!p)
					{
						while (calcWidth(s[0 .. p + 1]) <= width)
							p++;
						assert(p); // check if width can hold a single char
					}

					break;
				}

				p = next;
			}
			while (p != s.length && s[p].c != '\r' && s[p].c != '\n'); // eoi or newline

			res ~= s[0 .. p];
			s = s[p .. $];
		}

		return res;
	}

private:
	void skipWhitespaces(ref CharColor[] s)
	{
		while (s.length && s[0].c.isWhite)
			s.popFront;
	}

	auto calcWidth(CharColor[] s)
	{
		return _calcWidth(s.map!(a => a.c).toUTF8);
	}

	ushort delegate(string) _calcWidth;
}
