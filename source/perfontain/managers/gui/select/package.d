module perfontain.managers.gui.select;

import
		std.experimental.all,

		perfontain;

public import
				perfontain.managers.gui.select.box,
				perfontain.managers.gui.select.popup;


class Selector : GUIElement
{
	this(GUIElement p, bool followMouse = true)
	{
		super(p);
		_followMouse = followMouse;
	}

	void select(int) {}
private:
	mixin publicProperty!(int, `selected`, `-1`);

	void doSelect(int idx)
	{
		select(_selected = idx);
	}

	bool _followMouse;
}

class Selectable : GUIElement
{
	this(Selector p, int n = 0)
	{
		super(p, Vector2s.init, Win.captureFocus);

		idx = n;
	}

	override void draw(Vector2s p) const
	{
		if(selector._followMouse ? flags.hasMouse : selector._selected == idx)
		{
			drawQuad(p + pos, size, Color(0xa3, 0xdb, 0xfb, 0xff));
		}

		super.draw(p);
	}

	override void onPress(bool v)
	{
		if(flags.hasMouse && !v)
		{
			selector.doSelect(idx);
		}
	}

	int idx;
private:
	inout selector()
	{
		return cast(Selector)byHierarchy.find!(a => cast(Selector)a).front;
	}
}
