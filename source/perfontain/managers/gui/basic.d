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

		_c = c;
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, _c);

		super.draw(p);
	}

private:
	Color _c;
}

class GUIImage : GUIElement
{
	this(GUIElement parent, uint id, ubyte draw = 0, MeshHolder h = null)
	{
		_draw = draw;
		_id = cast(ushort)id;

		if(h)
		{
			_holder = h;
		}
		else
		{
			size = PE.gui.sizes[_id];

			if(draw & DRAW_ROTATE)
			{
				swap(size.x, size.y);
			}
		}

		super(parent);
	}

	override void draw(Vector2s p) const
	{
		drawImage(_holder ? _holder : PE.gui.holder, _id, p + pos, colorWhite, Vector2s.init, _draw);
	}

	override void onPress(bool b)
	{
		if(b && onClick)
		{
			onClick();
		}
	}

	void delegate() onClick;
protected:
	ushort _id;
	ubyte _draw;

	RC!MeshHolder _holder;
}

final class CheckBox : GUIElement
{
	this(GUIElement p, ushort id, Vector2s sz, bool ch = false)
	{
		super(p);

		_id = id;

		size = sz;
		checked = ch;
	}

	override void draw(Vector2s p) const
	{
		drawImage(_id + checked, p + pos);
	}

	bool checked;
	void delegate(bool) onChange;
protected:
	override void onPress(bool st)
	{
		if(st)
		{
			checked ^= true;

			if(onChange)
			{
				onChange(checked);
			}
		}
	}

private:
	ushort _id;
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
		super(e);

		size.y = PE.fonts.base.height;
	}

	override void draw(Vector2s p) const
	{
		p += pos;

		if(_ob)
		{
			drawImage(_ob, 0, p, colorBlack, Vector2s(_w, size.y));

			p.x += _w;
		}

		if(flags & WIN_HAS_INPUT && (PE.tick - _tick) % 1000 < 500)
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
		if(k == SDLK_BACKSPACE && st && _text.length)
		{
			_text.popBack;
			update;
		}
	}

	override void onText(string s)
	{
		if(!onChar || onChar(s))
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

	bool delegate(string)
							onChar,
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

			_ob = PEobjs.makeHolder(im, v)[0];
			_w = cast(ushort)min(im.w, x);
		}
	}

	string _text;
private:
	RC!MeshHolder _ob;

	ushort _w;
	uint _tick;
}

class GUIStaticText : GUIElement
{
	this(GUIElement p, string text, ubyte font = 0, Font f = null)
	{
		super(p);

		_font = font;
		_text = text;
		_f = f ? f : PE.fonts.base;

		flags = WIN_BACKGROUND;
		create;
	}

	override void onShow(bool b)
	{
		if(b)
		{
			create;
		}
		else
		{
			_ob = null;
		}

		//log(`text %s - %s`, b, _text);
	}

	override void draw(Vector2s p) const
	{
		drawImage(_ob, 0, p + pos, color);
	}

	Color color = colorBlack;
private:
	void create()
	{
		auto v = PEobjs.makeHolder(_f.render(_text, _font));

		_ob = v[0];
		size = v[1];
	}

	RC!Font _f;
	RC!MeshHolder _ob;

	ubyte _font;
	string _text;
}
