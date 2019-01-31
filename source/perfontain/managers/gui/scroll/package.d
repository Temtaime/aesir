module perfontain.managers.gui.scroll;

import
		std.utf,
		std.conv,
		std.regex,
		std.stdio,
		std.range,
		std.algorithm,

		core.bitop,

		perfontain,
		perfontain.managers.gui.scroll.sub;

public import
				perfontain.managers.gui.scroll.text;


final class Scrolled : GUIElement
{
	this(GUIElement parent, Vector2s sz, ushort h)
	{
		super(parent, Vector2s(0, sz.y * h));

		new Table(this, sz);
		new Scrollbar(this);


		toChildSize;
	}

	override void onResize()
	{
		bar.moveX(POS_MAX);
	}

	void add(GUIElement e)
	{
		table.add(e);
	}

private:
	mixin MakeChildRef!(Table, `table`, 0);
	mixin MakeChildRef!(Scrollbar, `bar`, 1);
}

class Scrollbar : GUIElement
{
	this(Scrolled s)
	{
		super(s);

		{
			auto e = new GUIImage(this, SCROLL_ARROW);
			size = Vector2s(e.size.x, s.size.y);
		}

		{
			auto e = new GUIImage(this, SCROLL_ARROW, DRAW_MIRROR_V);
			e.moveY(POS_MAX);
		}
	}
}
