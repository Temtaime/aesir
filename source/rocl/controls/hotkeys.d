module rocl.controls.hotkeys;

import
		std.meta,
		std.array,
		std.algorithm,

		perfontain,

		ro.conv.gui,

		rocl.game,
		rocl.network,
		rocl.controls;


class WinHotkeys : GUIElement
{
	this()
	{
		name = `hotkeys`;

		super(PE.gui.root);

		size = Vector2s(9, 4) * KS + Vector2s(SP + 10, SP);
		flags = WIN_MOVEABLE;

		if(pos.x < 0)
		{
			pos = PE.window.size - size - Vector2s(0, ROgui.chat.size.y);
		}
	}

	override void draw(Vector2s p) const
	{
		auto np = p + pos;

		drawQuad(np, size, colorWhite);

		foreach(x; 0..9)
		foreach(y; 0..4)
		{
			{
				auto r = np + Vector2s(x, y) * KS + Vector2s(SP);

				drawQuad(r, Vector2s(26, 1), Color(195, 195, 195, 255));
				drawQuad(r + Vector2s(0, 1), Vector2s(1, 25), Color(195, 195, 195, 255));
				drawQuad(r + Vector2s(25, 1), Vector2s(1, 25), Color(195, 195, 195, 255));
				drawQuad(r + Vector2s(1, 25), Vector2s(24, 1), Color(195, 195, 195, 255));
			}
		}

		if(_cur.x >= 0)
		{
			drawQuad(np + posOf(_cur), Vector2s(24), Color(0, 0, 255, 128));
		}

		super.draw(p);
	}

	override void onMove()
	{
		auto p = PE.window.mpos - pos - Vector2s(SP);

		auto ux = p.x % KS;
		auto uy = p.y % KS;

		if(ux >= 1 && ux <= 24 && uy >= 1 && uy <= 24)
		{
			_cur = p / KS;

			if(_cur.x < 9 && _cur.y < 4)
			{
				return;
			}
		}

		_cur.x = -1;
	}

	override void onHover(bool b)
	{
		if(!b)
		{
			_cur.x = -1;
		}
	}

	void add(ref PkHotkey h, Vector2s p)
	{
		if(h.isSkill)
		{
			if(auto s = RO.status.skillOf(cast(ushort)h.id))
			{
				add(new SkillIcon(this, s), p);
			}
		}
		else
		{
			auto s = RO.status.items.get(a => a.id == h.id);

			if(!s.empty)
			{
				add(new ItemIcon(this, s.front), p);
			}
		}
	}

	bool add(HotkeyIcon w, in Vector2s p = Vector2s(-1))
	{
		Vector2s q;

		if(p.x < 0)
		{
			if(_cur.x < 0)
			{
				return false;
			}

			q = _cur;
		}
		else
		{
			q = p;
		}

		w.attach(this);
		w.pos = posOf(q);

		{
			uint h;

			if(q.y)
			{
				auto z = (q.y - 1) * 9 + q.x;

				h = z >= hotkeys.length ? SDL_SCANCODE_COMMA + z - cast(uint)hotkeys.length : SDL_SCANCODE_A + hotkeys[z] - 'a';
			}
			else
			{
				h = SDL_SCANCODE_F1 + q.x;
			}

			auto f =
			{
				if(ROgui.chat.disabled)
				{
					w.use;
				}
			};

			w.bind(new Hotkey(f, h));
		}

		if(p.x < 0)
		{
			ROnet.setHotkey(q.y * 9 + q.x, w.hotkey);
		}

		w.flags &= ~(WIN_TOP_MOST | WIN_BACKGROUND);
		PE.gui.updateMouse;

		foreach(e; childs[0..$ - 1])
		{
			if(e.pos == w.pos)
			{
				e.remove;
				break;
			}
		}

		return true;
	}

	static immutable hotkeys = `qwertyuioasdfghjklzxcvbnm`;

//private:
	static posOf(Vector2s p)
	{
		return p * KS + Vector2s(SP + 1);
	}

	static fromPos(Vector2s p)
	{
		return (p - Vector2s(SP + 1)) / KS;
	}

	enum
			SP = 3,
			KS = SP + 26;

	Vector2s _cur = Vector2s(-1);
}
