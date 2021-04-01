module rocl.controller.npc;
import std.array, std.stdio, std.algorithm, perfontain, rocl, rocl.gui,
	rocl.game, rocl.network, rocl.controls, rocl.controls.colorbox;

struct NpcController
{
	void draw()
	{
		if (!_npc)
			return;

		auto rect = nk_rect(300, 300, 300, 300);

		if (auto win = Window(nk, nk.uniqueId, rect, NK_WINDOW_SCALABLE | NK_WINDOW_MOVABLE))
		{
			const buttons = _next || _close;

			{
				auto h = nk.usableHeight;

				if (buttons)
				{
					h -= nk.rowHeight;
					h -= nk.ctx.style.window.spacing.y;
				}

				nk.layout_row_dynamic(h, 1);
			}

			_box.draw;

			if (buttons)
			{
				with (LayoutRowTemplate(nk, 0))
				{
					dynamic;
					static_(80);
				}

				nk.spacing(1);

				if (_next)
				{
					if (nk.button(MSG_NEXT))
					{
						_next = false;
						ROnet.npcNext(_npc);
					}
				}
				else
				{
					if (nk.button(MSG_CLOSE))
					{
						cleanBox;
						ROnet.npcClose(_npc);

						_npc = 0;
						_close = false;
					}
				}
			}

			if (_select)
			{
				auto r = nk_rect(rect.w + 10, rect.h + 10, 200, 200);

				if (auto popup = Popup(nk, nk.uniqueId, r))
				{
					nk.layout_row_dynamic(0, 1);

					foreach (i, s; _select)
						if (nk.button(s))
						{
							popup.close;
							_select = null;

							ROnet.npcSelect(_npc, cast(uint)i + 1);
						}
				}
			}
		}
	}

	void mes(string s, uint npc)
	{
		_npc = npc;

		if (_clear)
		{
			cleanBox;
			_clear = false;
		}

		enum Color = `^ffffff`;

		_box.add(Color ~ s.replace(`^000000`, Color), colorTransparent);
	}

	void next()
	{
		_next = true;
		_clear = true;
	}

	void close()
	{
		_close = true;
	}

	void select(string[] s)
	{
		_select = s;
	}

	void remove()
	{
		_npc = 0;
		cleanBox;
	}

private:
	mixin Nuklear;

	void cleanBox()
	{
		_box = ColorBox.init;
	}

	uint _npc;
	bool _clear, _next, _close;

	ColorBox _box;
	string[] _select;
}
