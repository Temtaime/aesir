module rocl.controls.npc;

import
		std.meta,
		std.algorithm,

		perfontain,

		ro.conv.gui,

		rocl.controls;


class WinNpc : GUIElement
{
	this()
	{
		super(PE.gui.root);

		flags.moveable = true;
	}

	override void draw(Vector2s p) const
	{
		auto
				np = p + pos,
				sz = NPC_WIN_SZ;

		// left top
		drawImage(NPC_WIN, np, colorWhite, sz);

		// right top
		drawImage(NPC_WIN, np + Vector2s(size.x - sz.x, 0), colorWhite, sz, DRAW_MIRROR_H);

		{
			auto vp = np + Vector2s(0, size.y - sz.y);

			// left bottom
			drawImage(NPC_WIN, vp, colorWhite, sz, DRAW_MIRROR_V);

			// right bottom
			drawImage(NPC_WIN, vp + Vector2s(size.x - sz.x, 0), colorWhite, sz, DRAW_MIRROR_V | DRAW_MIRROR_H);
		}

		// spacers
		drawQuad(np + Vector2s(sz.x, 0), size - Vector2s(sz.x * 2, 0), colorWhite);
		drawQuad(np + Vector2s(0, sz.y), Vector2s(sz.x, size.y - sz.y * 2), colorWhite);
		drawQuad(np + Vector2s(size.x - sz.x, sz.y), Vector2s(sz.x, size.y - sz.y * 2), colorWhite);

		super.draw(p);
	}
}

final:

class WinNpcDialog : WinNpc
{
	this()
	{
		name = `npc`;
		size = Vector2s(320, 220);

		super();

		if(pos.x < 0)
		{
			pos = PE.window.size / 3;
		}

		{
			auto sz = size - NPC_WIN_SZ * 2 - Vector2s(0, BTN_PART_SZ.y + 6);

			new ScrolledText(this, Vector2s(sz.x, sz.y / PE.fonts.base.height));

			text.pos = NPC_WIN_SZ;
			text.autoBottom = false;
		}
	}

	auto makeButton(string s)
	{
		auto b = new Button(this, s);

		b.pos = size - b.size - Vector2s(NPC_WIN_SZ.x, 6);
		b.focus;

		PE.gui.updateMouse;
		return b;
	}

	auto text()
	{
		return cast(ScrolledText)childs[0];
	}
}

class WinNpcSelect : WinNpc
{
	this(WinNpcDialog diag, string[] arr)
	{
		size.x = 180;

		{
			auto h = PE.fonts.base.height;
			/*auto w = new Scrolled(this, Vector2s(size.x - NPC_WIN_SZ.x * 2, h), 4);

			w.pos = NPC_WIN_SZ;
			size.y = cast(short)(w.size.y + NPC_WIN_SZ.y * 2);*/

			{
				/*auto ds = new DialogSelector;
				auto ew = w.elemWidth;

				foreach(i, s; arr)
				{
					foreach(ts; toStaticTexts(s, Vector2s(ew, -1)))
					{
						auto e = new SelectableItem(null, ds);

						e.idx = cast(uint)i + 1;
						e.size = Vector2s(ew, PE.fonts.base.height);

						alias dg = (a)
						{
							a.pos.y = 0;
							a.attach(e);
						};

						ts.each!dg;
						w.add(e, true);
					}
				}*/
			}
		}

		super();

		pos = diag.pos + diag.size - size / 2;
	}

	void delegate(ubyte) onSelect;
private:
	/*class DialogSelector : Selector
	{
		override void select(int idx)
		{
			onSelect(cast(ubyte)idx);
		}
	}*/
}
