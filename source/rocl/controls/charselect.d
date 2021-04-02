module rocl.controls.charselect;

import std, perfontain, perfontain.opengl, ro.grf, ro.conv.gui, rocl,
	rocl.game, rocl.controls, rocl.network.packets;

final:

struct WinCharSelect //: GUIWindow
{
	void draw(in PkCharData* c)
	{
		auto rc = nk_rect(200, 200, 400, 400);

		if (auto win = Window(nk, MSG_CHAR_SELECT, rc))
		{
			nk.layout_row_dynamic(0, 2);

			if (nk.button(MSG_ENTER))
				RO.action.onCharSelected;

			if (nk.button(MSG_CREATE))
				RO.action.onCharCreate;

			nk.layout_row_dynamic(0, 4);

			foreach (s; stats(c))
			{
				nk.label(s.front);
				nk.label(s.back);
			}
		}
	}

private:
	mixin Nuklear;

	auto stats(in PkCharData* c)
	{
		string[2][] stats;

		void stat(T)(string name, T v)
		{
			auto s = v.to!string;

			static if (isIntegral!T)
			{
				s = s.as!ubyte.retro.chunks(3).join(' ').retro.array.assumeUTF;
			}

			stats ~= [name, s];
		}

		stat(`Name`, c.name);
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

		return stats;
	}
}

class StatInfo //: GUIElement
{
	//this(GUIElement p, string name, string value)
	//{
	// super(p, Vector2s(155, PE.fonts.base.height));

	// {
	// 	auto q = new GUIQuad(this, Color(200, 200, 230, 200));
	// 	q.size = Vector2s(48, size.y);

	// 	q = new GUIQuad(this, Color(240, 240, 240, 200));
	// 	q.size = Vector2s(size.x - 48, size.y);
	// 	q.moveX(POS_MAX);
	// }

	// {
	// 	FontInfo fi = {flags: FONT_BOLD};

	// 	auto e = new GUIStaticText(this, name, fi);
	// 	e.pos.x = 3;

	// 	e = new GUIStaticText(this, value);
	// 	e.pos.x = 51;
	// }
	//	}
}
