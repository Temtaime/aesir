module perfontain.managers.gui.basic;

import std, perfontain, nuklear;

public import perfontain.managers.gui.button, perfontain.managers.gui.label;

class GUIQuad : GUIElement
{
	this(GUIElement p, Color c)
	{
		//super(p);
		color = c;
	}

	Color color;
}

class Group_ : GUIElement
{
	this(GUIElement p, string title = null)
	{
		//super(p);
		_title = title;
	}

	override void draw()
	{
		// nk_layout_space_begin(ctx, NK_STATIC, 0, 1);

		// {
		// 	auto widget_bounds = nk_layout_widget_bounds(ctx);
		// 	auto content_bounds = nk_window_get_content_region(ctx);
		// 	float wdth = widget_bounds.w;
		// 	float hght = widget_bounds.h;
		// 	float pad = widget_bounds.y - content_bounds.y;
		// 	content_bounds.h -= pad;

		// 	//auto sz = nk_window_get_content_region_size(ctx);
		// 	//nk_layout_row_dynamic(ctx, hght, 1);

		// 	nk_layout_space_push(ctx, nk_rect(0, 0, wdth, content_bounds.h));
		// }

		// //nk_layout_row_dynamic(ctx, 0, 1);

		// //nk_layout_space_begin(ctx, NK_DYNAMIC, 100, 1);
		// //nk_layout_space_push(ctx, nk_rect_(0, 0, 1, 1));

		// if (nk_group_begin(ctx, _title.toStringz, (_title.length
		// 		? NK_WINDOW_TITLE : 0) | NK_WINDOW_BORDER))
		// {
		// 	super.setLayout;
		// 	//nk_layout_row_dynamic(ctx, 0, 1);
		// 	super.draw;
		// 	nk_group_end(ctx);
		// }

		// nk_layout_space_end(ctx);
	}

private:
	string _title;
}

// class Table : GUIElement
// {
// 	this(GUIElement p, Vector2s sz, ushort pad = 0)
// 	{
// 		super(p);

// 		_sz = sz;
// 		_pad = pad;
// 	}

// 	void add(GUIElement e)
// 	{
// 		//_elems ~= e;
// 		update;
// 	}

// 	void remove(GUIElement e)
// 	{
// 		e.deattach;
// 		//_elems.remove(e);

// 		_pos = min(_pos, maxIndex);
// 		update;
// 	}

// 	void pose(uint n)
// 	{
// 		_pos = n;
// 		update;
// 	}

// 	const rows()
// 	{
// 		return 0;//(cast(uint) _elems.length + _sz.x - 1) / _sz.x;
// 	}

// 	const maxIndex()
// 	{
// 		return uint(max(0, int(rows) - _sz.y));
// 	}

// 	inout elements()
// 	{
// 		return _elems[];
// 	}

// private:
// 	void update()
// 	{
// 		elements.each!(a => a.deattach);
// 		//childs.clear;

// 		auto sizes = _sz.x.iota.map!(a => elements.drop(a).stride(_sz.x).calcSize).array;

// 		auto xoff = _sz.x.iota.map!(a => sizes[0 .. a].map!(b => b.x).sum + a * _pad).array;

// 		auto sy = sizes.map!(a => a.y)
// 			.fold!max;

// 		// auto arr = _elems[_pos * _sz.x .. $][0 .. _sz.y ? min($, _sz.x * _sz.y) : $];

// 		// foreach (i, c; arr)
// 		// {
// 		// 	auto x = i % _sz.x, y = i / _sz.x;

// 		// 	auto e = new GUIElement(this, Vector2s(sizes[x].x, sy));

// 		// 	e.pos = Vector2s(xoff[x], (e.size.y + _pad) * y);
// 		// 	c.attach(e);
// 		// }

// 		toChildSize;
// 	}

// 	mixin publicProperty!(uint, `pos`);
// 	mixin publicProperty!(Vector2s, `sz`);

// 	//RCArray!GUIElement _elems;
// 	ushort _pad;
// }

class GUIImage : GUIElement
{
	this(GUIElement p, uint id, ubyte mode = 0, MeshHolder h = null)
	{
		// super(p);

		// _mode = mode;
		// _id = cast(ushort) id;

		// if (h)
		// {
		// 	_holder = h;
		// }
		// else
		// {
		// 	size = sizeFor(_id);

		// 	if (mode & DRAW_ROTATE)
		// 	{
		// 		swap(size.x, size.y);
		// 	}
		// }
	}

	void action(void delegate() dg)
	{
		_dg = dg;
		flags.captureFocus = !!dg;
	}

	override void onPress(Vector2s, bool v)
	{
		if (_dg && v)
		{
			_dg();
		}
	}

	auto color = colorWhite;
protected:
	void delegate() _dg;
	RC!MeshHolder _holder;

	ushort _id;
	ubyte _mode;
}

final class CheckBox : GUIElement
{
	this(Layout p, string text, bool checked_ = false)
	{
		super(p);

		_text = text;
		checked = checked_;
	}

	override void draw()
	{
		int ch = checked;
		if (nk_checkbox_text(ctx, _text.ptr, cast(uint) _text.length, &ch))
		{
			onChange(checked ^= true); // TODO: FIX CHANGE LOGIC
		}
	}

	bool checked;
	bool delegate(bool) onChange;
private:
	string _text;
}

// class Underlined : GUIElement
// {
// 	this(GUIElement e)
// 	{
// 		super(e);
// 	}

// 	void update()
// 	{
// 		toChildSize;
// 		size.y++;
// 	}
// }

class GUIEditText : GUIElement
{
	this()
	{
	}
	// 	this(GUIElement e)
	// 	{
	// 		super(e, Vector2s(0, PE.fonts.base.height), Win.enabled | Win.captureFocus);
	// 	}

	// 	override void onSubmit()
	// 	{
	// 		if (onEnter && onEnter(_text))
	// 		{
	// 			_text = null;
	// 			update;
	// 		}
	// 	}

	// 	override void onKey(uint k, bool st)
	// 	{
	// 		if (flags.enabled && k == SDLK_BACKSPACE && st && _text.length)
	// 		{
	// 			_text.popBack;
	// 			update;
	// 		}
	// 	}

	// 	override void onText(string s)
	// 	{
	// 		if (flags.enabled && (!onChar || onChar(s)))
	// 		{
	// 			_text ~= s;
	// 			update;
	// 		}
	// 	}

	// 	@property value()
	// 	{
	// 		return _text;
	// 	}

	// 	void clear()
	// 	{
	// 		_text = null;
	// 		update;
	// 	}

	// 	bool delegate(string) onChar, onEnter;
	// protected:
	// 	override void onFocus(bool b)
	// 	{
	// 		if (b)
	// 		{
	// 			input;
	// 			_tick = PE.tick;
	// 		}
	// 	}

	// 	void update()
	// 	{
	// 		_ob = null;

	// 		if (_text.length)
	// 		{
	// 			auto im = PE.fonts.base.render(_text);

	// 			auto x = size.x - 1;
	// 			auto v = max(float(im.w) - x, 0) / im.w;

	// 			_ob = PEobjs.makeHolder(im, v);
	// 			_w = cast(ushort) min(im.w, x);
	// 		}
	// 	}

	// 	string _text;
	// private:
	// 	RC!MeshHolder _ob;
	// 	uint _tick;
	// 	ushort _w;
}
