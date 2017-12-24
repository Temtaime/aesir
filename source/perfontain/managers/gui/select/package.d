module perfontain.managers.gui.select;

import
		perfontain;

public import
				perfontain.managers.gui.select.box,
				perfontain.managers.gui.select.popup;


enum : ubyte
{
	SEL_ON_PRESS = 1,
}

class Selector
{
	this(ubyte flags = 0)
	{
		_flags = flags;
	}

	void select(int) {}
private:
	mixin publicProperty!(int, `cur`, `-1`);

	void doSelect(int v)
	{
		select(_cur = v);
	}

	ubyte _flags;
}

class SelectableItem : GUIElement
{
	this(GUIElement p, Selector s)
	{
		_s = s;

		super(p);
	}

	override void draw(Vector2s p) const
	{
		if(_s._flags & SEL_ON_PRESS ? _s.cur == idx : flags & WIN_HAS_MOUSE)
		{
			drawQuad(p + pos, size, Color(0xa3, 0xdb, 0xfb, 0xff));
		}

		super.draw(p);
	}

	override void onPress(bool st)
	{
		if(flags & WIN_HAS_MOUSE && !st)
		{
			_s.doSelect(idx);
		}
	}

	int idx;
private:
	Selector _s;
}
