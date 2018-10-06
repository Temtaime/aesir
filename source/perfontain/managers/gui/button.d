module perfontain.managers.gui.button;

import
		perfontain;


final class Button : GUIElement
{
	this(GUIElement e, string s)
	{
		_text = s;

		make(2);
		make(0);

		super(e);
	}

	override void onSubmit()
	{
		if(enabled && onClick)
		{
			onClick();
		}
	}

	override void onPress(bool st)
	{
		if(!st && flags & WIN_HAS_MOUSE)
		{
			onSubmit;
		}

		make(st ? 2 : !!(flags & WIN_HAS_MOUSE));
	}

	override void onHover(bool st)
	{
		if(!(flags & WIN_PRESSED))
		{
			make(st ? 1 : 0);
		}
	}

	bool enabled = true;
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
		auto t = new GUIStaticText(this, _text, flags);

		if(!size.y)
		{
			size = Vector2s(size.x ? size.x : l.size.x * 2 + t.size.x, l.size.y);
		}

		r.moveX(null, POS_MAX);
		q.poseBetween(l, r);
		t.center;
	}

	string _text;
}
