module perfontain.managers.gui.scroll;

import
		std.algorithm,

		perfontain,
		perfontain.managers.gui.scroll.bar;

public import
				perfontain.managers.gui.scroll.text;


final:

class Scrolled : GUIElement
{
	this(GUIElement parent, Vector2s sz, ushort h)
	{
		super(parent, Vector2s(0, sz.y * h));

		new Table(this, sz);
		new Scrollbar(this);

		size.x = sbar.size.x;
		onCountChanged.permanent({ sbar.show(table.maxIndex > 0); });
	}

	override void onResize()
	{
		sbar.moveX(POS_MAX);
	}

	override bool onWheel(Vector2s v)
	{
		pose(clamp!int(table.pos - v.y, 0, table.maxIndex));
		return true;
	}

	void add(GUIElement e)
	{
		table.add(e);

		size.x = max(size.x, cast(short)(table.size.x + sbar.size.x));
		onResize;

		onCountChanged();
	}

	void remove(GUIElement e)
	{
		table.remove(e);
		onCountChanged();
	}

	void pose(uint n)
	{
		table.pose(n);
		onPosChanged(n);
	}

	Signal!void onCountChanged;
	Signal!(void, uint) onPosChanged;
package:
	mixin MakeChildRef!(Table, `table`, 0);
	mixin MakeChildRef!(Scrollbar, `sbar`, 1);
}
