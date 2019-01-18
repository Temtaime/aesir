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
	this(GUIElement parent, Vector2s sz, ushort n)
	{
		super(parent);

		sz.y *= n;
		size = sz;

		// container
		new GUIElement(this);

		Vector2s p;

		// arrow up
		{
			auto up = new GUIImage(this, SCROLL_ARROW);

			sz = up.size;
			p = size - sz;

			up.pos.x = p.x;

			up.onClick =
			{
				_idx--;
				update;
			};
		}

		container.size = Vector2s(p.x, size.y);

		// arrow down
		{
			auto down = new GUIImage(this, SCROLL_ARROW, DRAW_MIRROR_V);
			down.pos = p;

			down.onClick =
			{
				_idx++;
				update;
			};
		}

		// scroll holder
		{
			auto sp = new GUIElement(this);

			sp.pos = Vector2s(p.x, sz.y);
			sp.size = Vector2s(sz.x, p.y - sz.y);

			new Subscroll(sp, this, SCROLL_PART);
		}

		_n = n;
		update;
	}

	void clear()
	{
		_arr.clear;
		update;
	}

	void remove(GUIElement e)
	{
		_arr.remove(e);
		update;
	}

	ref rows()
	{
		return _arr;
	}

	void add(GUIElement e, bool reparent = false, bool toBottom = false)
	{
		if(reparent)
		{
			e.parent = container;
		}

		toBottom &= (_idx == maxIndex);
		_arr ~= e;

		if(toBottom)
		{
			_idx = maxIndex;
		}

		update;
	}

	void toPos(ushort p)
	{
		_idx = p;
		update;
	}

	override bool onWheel(Vector2s p)
	{
		_idx -= p.y;
		update;

		return true;
	}

	const elemWidth()
	{
		return container.size.x;
	}

package:
	void update()
	{
		auto u = maxIndex;
		_idx = max(min(_idx, u), 0);

		{
			auto v = u <= 0;
			childs[1..$].each!(a => a.flags.hidden = v);

			if(!v)
			{
				scroll.height = cast(ushort)(holderHeight * _n / cnt);
				scroll.update;
			}
		}

		showElements;
	}

	void showElements()
	{
		container.childs.clear;

		ushort p;
		auto e = min(_idx + _n, cnt);

		_arr[0.._idx]	.each!(a => a.show(false));
		_arr[e..$]		.each!(a => a.show(false));

		auto sub = _arr[_idx..e];

		foreach(c; sub)
		{
			c.show;
			c.pos.y = p;

			p += elemHeight;
			container.childs ~= c;
		}
	}

	auto maxIndex()
	{
		return cnt - _n;
	}

	auto holderHeight()
	{
		return childs.back.size.y;
	}

	auto cnt()
	{
		return cast(int)_arr.length;
	}

	auto scroll()
	{
		return cast(Subscroll)childs.back.childs.front;
	}

	inout container()
	{
		return childs.front;
	}

	auto elemHeight()
	{
		return cast(ushort)(size.y / _n);
	}

	int _idx;
	ushort _n;

	RCArray!GUIElement _arr;
}
