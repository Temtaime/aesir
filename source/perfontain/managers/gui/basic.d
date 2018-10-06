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
	this(GUIElement parent, uint id, ubyte mode = 0, MeshHolder h = null)
	{
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

		super(parent, Vector2s.init, WIN_BACKGROUND);
	}

	override void draw(Vector2s p) const
	{
		drawImage(_holder ? _holder : PE.gui.holder, _id, p + pos, color, Vector2s.init, _mode);
	}

	override void onPress(bool b)
	{
		if(onClick && b)
		{
			onClick();
		}
	}

	auto color = colorWhite;
	void delegate() onClick;
protected:
	RC!MeshHolder _holder;
	ushort _id;
	ubyte _mode;
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

		if(enabled && flags & WIN_HAS_INPUT && (PE.tick - _tick) % 1000 < 500)
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
		if(enabled && k == SDLK_BACKSPACE && st && _text.length)
		{
			_text.popBack;
			update;
		}
	}

	override void onText(string s)
	{
		if(enabled && (!onChar || onChar(s)))
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

	bool enabled = true;

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

			_ob = PEobjs.makeHolder(im, v);
			_w = cast(ushort)min(im.w, x);
		}
	}

	string _text;
private:
	RC!MeshHolder _ob;

	ushort _w;
	uint _tick;
}

class GUIStaticText : GUIImage
{
	this(GUIElement p, string text, ubyte font = 0, Font f = null, short maxWidth = short.max)
	{
		f = f ? f : PE.fonts.base;

		auto arr = f.toLines(text, maxWidth, 1, font);
		assert(arr.length == 1);

		auto m = PEobjs.makeHolder(f.render(arr[0], font));

		size = m.size;
		color = colorBlack;

		super(p, 0, 0, m);
	}
}
