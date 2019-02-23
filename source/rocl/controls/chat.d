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
		super(PE.gui.root, Vector2s.init, Win.moveable, `chat`);

		{
			new ScrolledText(this, Vector2s(660, 5));
			new GUIEditText(this);

			edit.moveY(sc, POS_ABOVE);
			edit.size.x =cast(ushort)(sc.size.x - CHAT_PART_SZ.x * 2);

			edit.onEnter = (a)
			{
				if(a.length)
				{
					ROnet.toChat(a);
					return true;
				}
				else
				{
					edit.flags.enabled = disabled;
				}

				return false;
			};
		}

		toChildSize;
		pad(4);

		tryPose;
		edit.focus;
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
		return !edit.flags.enabled;
	}

private:
	static szY()
	{
		return CHAT_PART_SZ.y;
	}

	mixin MakeChildRef!(ScrolledText, `sc`, 0);
	mixin MakeChildRef!(GUIEditText, `edit`, 1);
}
