module rocl.controls.charselect;

import
		std,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.controls,
		rocl.network.packets;


final:

class WinCharSelect : WinBasic2
{
	this(in PkCharData *c)
	{
		super(MSG_CHAR_SELECT, `char_select`);

		{
			auto v = PE.window.size;
			pos = Vector2s(v.x * 2 / 3 - size.x / 2, v.y / 3 - size.y);
		}

		{
			string[2][] stats;

			void stat(T)(string name, T v)
			{
				auto s = v.to!string;

				static if(isIntegral!T)
				{
					s = s.as!ubyte.retro.chunks(3).join(' ').retro.array.assumeUTF;
				}

				stats ~= [ name, s ];
			}

			stat(`Name`, c.name.charsToString);
			stat(`STR`, c.str);

			stat(`Job`, `???`);
			stat(`AGI`, c.agi);

			stat(`Lv.`, c.baseLvl);
			stat(`VIT`, c.vit);

			stat(`EXP`, c.baseExp);
			stat(`INT`, c.int_);

			stat(`HP`, c.hp);
			stat(`DEX`, c.dex);

			stat(`SP`, c.sp);
			stat(`LUK`, c.luk);

			auto t = new Table(main, Vector2s(2, 0), 2);

			stats.each!(a => t.add(new StatInfo(null, a.front, a.back)));
		}

		adjust;

		{
			auto b = new Button(bottom, MSG_ENTER, &RO.action.onCharSelected);

			b.move(POS_MIN, 4, POS_CENTER);
			b.focus;
		}

		{
			auto b = new Button(bottom, MSG_CREATE, &RO.action.onCharCreate);
			b.move(POS_MAX, -4, POS_CENTER);
		}
	}
}

class StatInfo : GUIElement
{
	this(GUIElement p, string name, string value)
	{
		super(p, Vector2s(155, PE.fonts.base.height));

		{
			auto q = new GUIQuad(this, Color(200, 200, 230, 200));
			q.size = Vector2s(48, size.y);

			q = new GUIQuad(this, Color(240, 240, 240, 200));
			q.size = Vector2s(size.x - 48, size.y);
			q.moveX(POS_MAX);
		}

		{
			FontInfo fi =
			{
				flags: FONT_BOLD
			};

			auto e = new GUIStaticText(this, name, fi);
			e.pos.x = 3;

			e = new GUIStaticText(this, value);
			e.pos.x = 51;
		}
	}
}
