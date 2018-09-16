module rocl.controls.creation;

import
		std.conv,
		std.range,
		std.string,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.controls,
		rocl.network.packets;


final:

class WinCreation : WinBasic
{
	this()
	{
		//name = `char_creation`;

		super(Vector2s(280, 140), MSG_CHAR_CREATION);

		{
			auto v = PE.window.size;
			pos = Vector2s(v.x * 2 / 3 - size.x / 2, v.y / 3 - size.y);
		}

		_style = new ValueSelector(this, 80, 12);
		_style.pos = Vector2s(WIN_TOP_SZ.y) + Vector2s(0, 5 + _style.size.y);

		_style.onChange = () => create(true);

		{
			auto t = new GUIStaticText(this, MSG_HAIR_STYLE);
			t.move(_style, POS_MIN, 0, _style, POS_BELOW, 0);
		}

		_color = new ValueSelector(this, 80, 8);
		_color.move(_style, POS_ABOVE, 10, _style, POS_MIN, 0);

		_color.onChange = () => create(true);

		{
			auto t = new GUIStaticText(this, MSG_HAIR_COLOR);
			t.move(_color, POS_MIN, 0, _style, POS_BELOW, 0);
		}

		{
			auto n = new GUIStaticText(this, MSG_CHAR_NAME);
			n.move(_style, POS_MIN, 0, _style, POS_ABOVE, 6);

			auto u = new Underlined(this);

			_name = new class GUIEditText
			{
				this()
				{
					super(u);
				}

				override void onText(string s)
				{
					auto n = _text ~ s;

					if(n.representation.length < 24)
					{
						_text = n;
						update;
					}
				}
			};

			_name.focus;
			_name.size.x = _style.size.x;

			u.update;
			u.move(n, POS_MIN, 0, n, POS_ABOVE, 2);
		}

		{
			auto b = new Button(this, MSG_CREATE);

			b.pos = Vector2s(5, size.y - b.size.y - 4);
			b.onClick = &onCreate;
		}

		if(ROnet.st.chars.length)
		{
			auto b = new Button(this, MSG_CANCEL);
			b.pos = Vector2s(size.x - b.size.x - 5, size.y - b.size.y - 4);

			b.onClick =
			{
				RO.gui.removeCreation;
				RO.action.charSelect(0);
			};
		}

		create(false);
	}

	void onDone(ref PkCharData p)
	{
		RO.gui.removeCreation;

		with(ROnet.st)
		{
			chars ~= p;
			RO.action.charSelect(cast(uint)chars.length - 1);
		}
	}

	void onError(byte code)
	{
	}

private:
	void create(bool remove)
	{
		import rocl.entity.misc;

		auto n = cast(uint)ROnet.st.chars.length;

		if(remove)
		{
			ROent.remove(n);
		}

		PkCharData c;

		c.hairStyle = _style.value;
		c.hairColor = _color.value;

		`?`.copy(c.name[]);

		auto e = ROent.createChar(&c, n, ROnet.st.gender);
		e.fix(Vector2s(259 + n * 2, 190).PosDir);
	}

	void onCreate()
	{
		ROnet.createChar(_name.value, _color.value, _style.value);
	}

	GUIEditText _name;

	ValueSelector
					_style,
					_color;
}

private:

class ValueSelector : GUIElement
{
	this(GUIElement p, ushort w, ubyte m)
	{
		super(p);

		size = Vector2s(w + SCROLL_ARROW_SZ.y * 2 + 10, max(PE.fonts.base.height, SCROLL_ARROW_SZ.x));

		auto u1 = new GUIImage(this, SCROLL_ARROW, DRAW_ROTATE | DRAW_MIRROR_V);
		u1.move(this, POS_MIN, 5, this, POS_CENTER, 0);

		auto t = new GUIStaticText(this, 1.to!string);
		t.move(this, POS_CENTER, 0, this, POS_CENTER, 0);

		auto u2 = new GUIImage(this, SCROLL_ARROW, DRAW_ROTATE);
		u2.move(this, POS_MAX, -5, this, POS_CENTER, 0);

		size.x = cast(short)(u2.end.x + 5);

		u1.onClick =
		{
			update(-1);
		};

		u2.onClick =
		{
			update(1);
		};

		_max = m;
		value = 1;
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, Color(240, 240, 240, 200));

		super.draw(p);
	}

	ubyte value;

	void delegate() onChange;
private:
	void update(byte d)
	{
		auto n = cast(byte)(value + d);

		if(n >= 1 && n <= _max)
		{
			value = n;
			auto e = new GUIStaticText(null, value.to!string);

			e.parent = this;
			e.move(this, POS_CENTER, 0, this, POS_CENTER, 0);

			childs[childs.length - 2] = e;

			onChange();
		}
	}

	ubyte _max;
}
