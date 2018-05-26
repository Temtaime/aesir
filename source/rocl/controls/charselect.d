module rocl.controls.charselect;

import
		std.experimental.all,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.controls,
		rocl.network.packets;


final:

class WinCharSelect : WinBasic
{
	this(in PkCharData *c)
	{
		name = `char_select`;

		super(Vector2s(340, 200), MSG_CHAR_SELECT);

		{
			auto v = PE.window.size;
			pos = Vector2s(v.x * 2 / 3 - size.x / 2, v.y / 3 - size.y);
		}

		string[2][] stats;

		void stat(T)(string name, T v)
		{
			auto s = v.to!string;

			static if(is(T : int))
			{
				s = s.as!ubyte.retro.chunks(3).join(' ').retro.array.assumeUTF;
			}

			stats ~= [ name, s ];
		}

		stat(`Name`, c.name.charsToString);
		stat(`Job`, `???`);
		stat(`Lv.`, c.baseLvl);
		stat(`EXP`, c.baseExp);
		stat(`HP`, c.hp);
		stat(`SP`, c.sp);

		stat(`STR`, c.str);
		stat(`AGI`, c.agi);
		stat(`VIT`, c.vit);
		stat(`INT`, c.int_);
		stat(`DEX`, c.dex);
		stat(`LUK`, c.luk);

		foreach(i, s; stats)
		{
			auto w = new StatInfo(this, s.front, s.back);

			w.pos = Vector2s(20, 30 + (w.size.y + 2) * (i % 6));

			if(i >= 6)
			{
				w.pos.x += w.size.x + 2;
			}
		}

		{
			auto b = new Button(this, BTN_PART, MSG_ENTER);

			b.pos = Vector2s(4, size.y - b.size.y - 4);
			b.onClick = &RO.action.onCharSelected;

			b.focus;
		}

		{
			auto b = new Button(this, BTN_PART, MSG_CREATE);

			b.pos = Vector2s(size.x - b.size.x - 4, size.y - b.size.y - 4);
			b.onClick = &RO.action.onCharCreate;
		}
	}
}

class StatInfo : GUIElement
{
	this(WinCharSelect w, string name, string value)
	{
		super(w);

		size = Vector2s(155, PE.fonts.base.height);

		{
			auto e = new GUIStaticText(this, name, FONT_BOLD);
			e.pos.x = 3;
		}

		{
			auto e = new GUIStaticText(this, value);
			e.pos.x = 51;
		}
	}

	override void draw(Vector2s p) const
	{
		auto np = p + pos;

		drawQuad(np, Vector2s(48, size.y), Color(200, 200, 230, 200));
		drawQuad(np + Vector2s(48, 0), Vector2s(size.x - 48, size.y), Color(240, 240, 240, 200));

		super.draw(p);
	}
}
