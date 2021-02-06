module perfontain.managers.font.splitter;

import std.utf, std.ascii, std.range, std.algorithm, stb.image, perfontain;

struct CharColor
{
	dchar c;
	Color color;
}

//package:

struct LineSplitter
{
	this(uint delegate(string) size, short w, short ls = -1)
	{
		_size = size;

		_width = w;
		_lines = ls;

		_cw = cast(ushort)size(CONT);
		assert(w >= _cw);
	}

	auto split(CharColor[] text)
	{
		CharColor[][] res;

		auto arr = text.splitter!(a => a.c == '\n');

		lines: while (!arr.empty)
		{
			auto s = arr.front;
			arr.popFront;

			auto words = s.split!(a => a.c.isWhite)
				.filter!(a => a.length);

			loop: while (true)
			{
				res.length++;

				auto n = _width;
				auto end = res.length == _lines;

				while (!words.empty)
				{
					auto w = words.front;
					auto firstWord = n == _width;

					auto u = firstWord ? w : CharColor(' ', w[0].color) ~ w;
					auto len = size(u);

					if (n >= len)
					{
						words.popFront;

						if (end)
						{
							if (!words.empty || !arr.empty)
							{
								if (n < len + _cw)
								{
									uint k;

									n -= _cw;

									for (; size(u[0 .. k + 1]) <= n; k++)
									{
									}

									if (firstWord || k > 1)
									{
										res.back ~= u[0 .. k];
									}

									res.back ~= CONT.map!(a => CharColor(a, w[0].color)).array;
									break lines;
								}
							}
						}

						n -= len;
						res.back ~= u;
					}
					else
					{
						if (firstWord)
						{
							uint k;

							if (end)
							{
								n -= _cw;
							}

							for (; size(w[0 .. k + 1]) <= n; k++)
							{
							}

							res.back ~= w[0 .. k];

							if (end)
							{
								res.back ~= CONT.map!(a => CharColor(a, w[0].color)).array;
								break lines;
							}
							else
							{
								assert(k);
							}

							words.front.popFrontN(k);
						}
						else if (end)
						{
							res.back ~= CONT.map!(a => CharColor(a, w[0].color)).array;
							break lines;
						}

						continue loop;
					}
				}

				break;
			}
		}

		return res;
	}

private:
	static immutable CONT = `...`;

	const size(in CharColor[] s)
	{
		return _size(s.map!(a => a.c).array.toUTF8);
	}

	uint delegate(string) _size;

	short _cw, _width, _lines = -1;
}
