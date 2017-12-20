module rocl.controls.chat;

import
		std.utf,
		std.array,

		perfontain,

		ro.conv.gui,

		rocl.game;


final class RoChat : GUIElement
{
	this(bool online = true)
	{
		name = `chat`;
		flags = WIN_MOVEABLE;

		super(PE.gui.root);

		size.x = 670;

		{
			auto w = new ScrolledText(this, Vector2s(size.x - 8, 5), SCROLL_ARROW);
			w.pos = Vector2s(4);

			size.y = cast(ushort)(w.size.y + szY + 8);
		}

		if(pos.x < 0)
		{
			pos = parent.size - size;
		}

		//createEdit;
		_cp = PE.onKey.add(&onKey); // TODO: FIX

		_online = online;
	}

	void add(string s, Color c = colorTransparent)
	{
		sc.add(s, c);
	}

	override void draw(Vector2s p) const
	{
		auto h = size.y - CHAT_PART_SZ.y;

		auto
				np = p + pos,
				vp = np + Vector2s(0, h);

		drawQuad(np, Vector2s(size.x, h), Color(0, 0, 0, 110));

		drawImage(CHAT_PART, vp, colorWhite, CHAT_PART_SZ);
		drawImage(CHAT_SPACER, vp + Vector2s(CHAT_PART_SZ.x, 0), colorWhite, Vector2s(size.x - CHAT_PART_SZ.x * 2, CHAT_PART_SZ.y));
		drawImage(CHAT_PART, vp + Vector2s(size.x - CHAT_PART_SZ.x, 0), colorWhite, CHAT_PART_SZ, DRAW_MIRROR_H);

		super.draw(p);
	}

	const disabled()
	{
		return childs.length == 1;
	}

private:
	static szY()
	{
		return CHAT_PART_SZ.y;
	}

	void onKey(uint k, bool p)
	{
		if(flags & WIN_HIDDEN)
		{
			return;
		}

		if(k == SDLK_RETURN || k == SDLK_KP_ENTER) // TODO: COMMON FUNC
		{
			if(!p && disabled)
			{
				_cp = null;
				createEdit;
			}
		}
	}

	void createEdit()
	{
		auto e = new GUIEditText(this);

		e.pos = Vector2s(7, size.y - szY + (szY - e.size.y) / 2);
		e.size.x = cast(ushort)(size.x - e.pos.x * 2);

		e.onEnter = (a)
		{
			if(a.length)
			{
				if(_online)
				{
					ROnet.toChat(a);
				}
				else
				{
					try ROres.load(a); catch(Exception e) e.log;
				}

				return true;
			}
			else
			{
				e.remove;
				_cp = PE.onKey.add(&onKey);
			}

			return false;
		};

		e.focus;
	}

	auto sc()
	{
		return cast(ScrolledText)childs[0];
	}

	bool _online;
	RC!ConnectionPoint _cp;
}
