module perfontain.managers.gui.basic;

import
		std.range,
		std.stdio,
		std.algorithm,

		perfontain;

public import
				perfontain.managers.gui.button;


class GUIQuad : GUIElement
{
	this(GUIElement p, Color c)
	{
		super(p);
		color = c;
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, color);

		super.draw(p);
	}

	Color color;
}

class Table : GUIElement
{
	this(GUIElement p, Vector2s sz, ushort pad = 0)
	{
		super(p);

		_sz = sz;
		_pad = pad;
	}

	void add(GUIElement e)
	{
		_elems ~= e;
		update;
	}

	void remove(GUIElement e)
	{
		e.deattach;
		_elems.remove(e);

		_pos = min(_pos, maxIndex);
		update;
	}

	void pose(uint n)
	{
		_pos = n;
		update;
	}

	const rows()
	{
		return (cast(uint)_elems.length + _sz.x - 1) / _sz.x;
	}

	const maxIndex()
	{
		return uint(max(0, int(rows) - _sz.y));
	}

	inout elements()
	{
		return _elems[];
	}

private:
	void update()
	{
		elements.each!(a => a.deattach);
		childs.clear;

		auto sizes = _sz.x
							.iota
							.map!(a => elements.drop(a).stride(_sz.x).calcSize)
							.array;

		auto xoff = _sz.x
							.iota
							.map!(a => sizes[0..a].map!(b => b.x).sum + a * _pad)
							.array;

		auto sy = sizes
						.map!(a => a.y)
						.fold!max;

		auto arr = _elems[_pos * _sz.x..$][0.._sz.y ? min($, _sz.x * _sz.y) : $];

		foreach(i, c; arr)
		{
			auto	x = i % _sz.x,
					y = i / _sz.x;

			auto e = new GUIElement(this, Vector2s(sizes[x].x, sy));

			e.pos = Vector2s(xoff[x], (e.size.y + _pad) * y);
			c.attach(e);
		}

		toChildSize;
	}

	mixin publicProperty!(uint, `pos`);
	mixin publicProperty!(Vector2s, `sz`);

	RCArray!GUIElement _elems;
	ushort _pad;
}

class GUIImage : GUIElement
{
	this(GUIElement p, uint id, ubyte mode = 0, MeshHolder h = null)
	{
		super(p);

		_mode = mode;
		_id = cast(ushort)id;

		if(h)
		{
			_holder = h;
		}
		else
		{
			size = sizeFor(_id);

			if(mode & DRAW_ROTATE)
			{
				swap(size.x, size.y);
			}
		}
	}

	void action(void delegate() dg)
	{
		_dg = dg;
		flags.captureFocus = !!dg;
	}

	override void draw(Vector2s p) const
	{
		drawImage(_holder ? _holder : PE.gui.holder, _id, p + pos, color, Vector2s.init, _mode);
	}

	override void onPress(Vector2s, bool v)
	{
		if(_dg && v)
		{
			_dg();
		}
	}

	auto color = colorWhite;
protected:
	void delegate() _dg;
	RC!MeshHolder _holder;

	ushort _id;
	ubyte _mode;
}

final class CheckBox : GUIImage
{
	this(GUIElement p, bool ch = false)
	{
		super(p, ch ? CHECKBOX_CHECKED : CHECKBOX);

		checked = ch;
		flags.captureFocus = true;
	}

	bool checked;
	void delegate(bool) onChange;
protected:
	override void onPress(Vector2s, bool st)
	{
		if(st)
		{
			checked ^= true;

			if(onChange)
			{
				onChange(checked);
			}

			_id = checked ? CHECKBOX_CHECKED : CHECKBOX;
		}
	}
}

class Underlined : GUIElement
{
	this(GUIElement e)
	{
		super(e);
	}

	void update()
	{
		toChildSize;
		size.y++;
	}

	override void draw(Vector2s p) const
	{
		super.draw(p);

		drawQuad(p + pos + Vector2s(0, size.y - 1), Vector2s(size.x, 1), Color(128, 128, 128, 200));
	}
}

class GUIEditText : GUIElement
{
	this(GUIElement e)
	{
		super(e, Vector2s(0, PE.fonts.base.height), Win.enabled | Win.captureFocus);
	}

	override void draw(Vector2s p) const
	{
		p += pos;

		if(_ob)
		{
			drawImage(_ob, 0, p, colorBlack, Vector2s(_w, size.y));

			p.x += _w;
		}

		if(flags.enabled && flags.hasInput && (PE.tick - _tick) % 1000 < 500)
		{
			drawQuad(p, Vector2s(1, size.y), colorBlack);
		}
	}

	override void onSubmit()
	{
		if(onEnter && onEnter(_text))
		{
			_text = null;
			update;
		}
	}

	override void onKey(uint k, bool st)
	{
		if(flags.enabled && k == SDLK_BACKSPACE && st && _text.length)
		{
			_text.popBack;
			update;
		}
	}

	override void onText(string s)
	{
		if(flags.enabled && (!onChar || onChar(s)))
		{
			_text ~= s;
			update;
		}
	}

	@property value()
	{
		return _text;
	}

	void clear()
	{
		_text = null;
		update;
	}

	bool delegate(string)	onChar,
							onEnter;
protected:
	override void onFocus(bool b)
	{
		if(b)
		{
			input;
			_tick = PE.tick;
		}
	}

	void update()
	{
		_ob = null;

		if(_text.length)
		{
			auto im = PE.fonts.base.render(_text);

			auto x = size.x - 1;
			auto v = max(float(im.w) - x, 0) / im.w;

			_ob = PEobjs.makeHolder(im, v);
			_w = cast(ushort)min(im.w, x);
		}
	}

	string _text;
private:
	RC!MeshHolder _ob;
	uint _tick;
	ushort _w;
}

class GUIStaticText : GUIImage
{
	this(GUIElement p, string text, FontInfo fi = FontInfo.init, ubyte mode = 0)
	{
		//super(p);
		auto e = fi.font ? fi.font : PE.fonts.base;

		auto arr = e.toLines(text, fi.maxWidth, 1, fi.flags);
		assert(arr.length == 1);

		auto m = PEobjs.makeHolder(e.render(arr[0], fi.flags));

		super(p, 0, mode, m);
		//new GUIImage(this, 0, mode, m).size = m.size;

		color = colorBlack;
		size = Vector2s(m.size.x, e.height);
	}

	//auto color = colorBlack;
}

struct FontInfo // TODO: REPLACE OTHER USAGES
{
	Font font;
	short maxWidth = short.max;
	ubyte flags;
}
