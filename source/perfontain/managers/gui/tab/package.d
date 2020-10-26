module perfontain.managers.gui.tab;

import
		std,

		perfontain;

public import
				perfontain.managers.gui.tab.selector;


// abstract class TabsWindow : GUIElement
// {
// 	this(GUIElement p, ubyte n)
// 	{
// 		super(p);

// 		foreach(_; 0..n)
// 		{
// 			new GUIElement(this, Vector2s.init, Win.hidden);
// 		}
// 	}

// 	void adjust()
// 	{
// 		tabs.each!(a => a.toChildSize);
// 		toChildSize;
// 	}

// 	void select(ubyte n)
// 	{
// 		tabs[_idx].show(false);
// 		tabs[_idx = n].show;
// 	}

// 	inout(GUIElement)[] tabs() inout;

// 	inout tab()
// 	{
// 		return tabs[_idx];
// 	}

// protected:
// 	mixin publicProperty!(ubyte, `idx`);
// }

// final class TabWindow : GUIElement // TODO: MIGRATE
// {
// 	this(GUIElement p, ushort w, ushort[] sz, ushort id, short h = -1)
// 	{
// 		super(p);

// 		foreach(i; 0..cast(uint)sz.length)
// 		{
// 			auto im = new GUIImage(this, id + i);

// 			if(i)
// 			{
// 				im.show(false);
// 			}
// 			else
// 			{
// 				size = im.size;
// 			}

// 			//im.flags.background = true;
// 		}

// 		{
// 			ushort y;

// 			foreach(u; sz)
// 			{
// 				auto s = new TabSelector(this);

// 				s.pos = Vector2s(0, y);
// 				s.size = Vector2s(size.x, u);

// 				y += u;
// 			}
// 		}

// 		if(h >= 0)
// 		{
// 			size.y = h;
// 		}

// 		foreach(i; 0..sz.length)
// 		{
// 			auto e = new GUIElement(this);

// 			if(i)
// 			{
// 				e.show(false);
// 			}

// 			e.pos.x = size.x;
// 			e.size = Vector2s(w, size.y);
// 		}

// 		size.x += w;
// 	}

// 	inout tab()
// 	{
// 		return tabs[_tabIdx];
// 	}

// 	inout tabs()
// 	{
// 		return childs[$ - cnt..$];
// 	}

// 	void delegate(ubyte) onTabChange;
// private:
// 	mixin publicProperty!(ubyte, `tabIdx`);

// 	const cnt()
// 	{
// 		return cast(uint)childs.length / 3;
// 	}

// package:
// 	inout selectors()
// 	{
// 		return childs[cnt..cnt * 2];
// 	}

// 	void onChange(ubyte n)
// 	{
// 		childs[_tabIdx].show(false);
// 		tabs[_tabIdx].show(false);

// 		childs[_tabIdx = n].show;
// 		tabs[n].show;

// 		if(onTabChange)
// 		{
// 			onTabChange(n);
// 		}
// 	}
// }
