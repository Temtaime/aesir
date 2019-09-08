module perfontain.managers.gui.button;

import
		perfontain;


final class Button : GUIElement
{
	this(GUIElement e, string s, void delegate() f = null)
	{
		super(e, Vector2s.init, Win.enabled | Win.captureFocus, s);

		make(2);
		make(0);

		onClick = f;
	}

	override void onSubmit()
	{
		if(flags.enabled && onClick)
		{
			onClick();
		}
	}

	override void onPress(Vector2s, bool st)
	{
		make(st ? 2 : flags.hasMouse);

		if(!st && flags.hasMouse)
		{
			onSubmit;
		}
	}

	override void onHover(bool st)
	{
		if(!flags.pressed)
		{
			make(st ? 1 : 0);
		}
	}

	override void onResize()
	{
		make(0);
	}

	void delegate() onClick;
private:
	void make(ubyte idx)
	{
		final switch(idx)
		{
		case 0:
			make(BTN_PART, BTN_SPACER, 0);
			break;
		case 1:
			make(BTN_HOVER_PART, BTN_HOVER_SPACER, 0);
			break;
		case 2:
			make(BTN_HOVER_PART, BTN_HOVER_SPACER, FONT_BOLD);
		}
	}

	auto make(ushort id, ushort spacer, ubyte flags)
	{
		childs.clear;

		auto l = new GUIImage(this, id);
		auto r = new GUIImage(this, id, DRAW_MIRROR_H);
		auto q = new GUIImage(this, spacer);

		FontInfo fi =
		{
			flags: flags
		};

		auto t = new GUIStaticText(this, name, fi);

		if(!size.y)
		{
			size = Vector2s(size.x ? size.x : l.size.x * 2 + t.size.x, l.size.y);
		}

		r.moveX(POS_MAX);
		q.poseBetween(l, r);
		t.center;
	}
}
