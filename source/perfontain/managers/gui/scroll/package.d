module perfontain.managers.gui.scroll;

import std.algorithm, perfontain, perfontain.managers.gui.scroll.bar;

public import perfontain.managers.gui.scroll.text;

final:

// class Scrolled : GUIElement
// {
// 	this(GUIElement parent, Vector2s sz, ushort h)
// 	{
// 		super(parent, Vector2s(SCROLL_ARROW_SZ.x, sz.y * h), Win.captureFocus);

// 		new Table(this, sz);

// 		onCountChanged.permanent(&makeBar);
// 	}

// 	override void onResize()
// 	{
// 		if (sbar)
// 		{
// 			sbar.moveX(POS_MAX);
// 		}
// 	}

// 	override bool onWheel(Vector2s v)
// 	{
// 		pose(clamp!int(table.pos - v.y, 0, table.maxIndex));
// 		return true;
// 	}

// 	/*void clear()
// 	{
// 		//childs[0] = new Table(this, table.sz);
// 	}*/

// 	void add(GUIElement e)
// 	{
// 		table.add(e);

// 		size.x = max(size.x, cast(short)(table.size.x + SCROLL_ARROW_SZ.x));
// 		onResize;

// 		onCountChanged();
// 	}

// 	void remove(GUIElement e)
// 	{
// 		table.remove(e);
// 		onCountChanged();
// 	}

// 	void pose(uint n)
// 	{
// 		table.pose(n);
// 		onPosChanged(n);
// 	}

// 	const width()
// 	{
// 		return cast(ushort)(size.x - SCROLL_ARROW_SZ.x);
// 	}

// 	const maxIndex()
// 	{
// 		return table.maxIndex;
// 	}

// 	inout elements()
// 	{
// 		return table.elements;
// 	}

// 	Signal!void onCountChanged;
// 	Signal!(void, uint) onPosChanged;
// package:
// 	mixin MakeChildRef!(Table, `table`, 0);
// 	mixin MakeChildRef!(Scrollbar, `sbar`, 1);
// private:
// 	void makeBar()
// 	{
// 		if (table.maxIndex)
// 		{
// 			if (!sbar)
// 			{
// 				new Scrollbar(this);
// 				onResize;
// 			}
// 		}
// 		else if (sbar)
// 		{
// 			sbar.deattach;
// 		}
// 	}
// }
