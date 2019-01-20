module perfontain.managers.gui.select.box;

import
		std.experimental.all,

		perfontain;


immutable borderColor = Color(200, 200, 200, 255);

final:

class SelectBox : GUIElement
{
	this(GUIElement p, GUIElement[] arr, int idx = -1)
	{
		assert(arr.length);
		super(p, arr.calcSize);

		new GUIImage(this, SELECT_ARROW);
		new GUIElement(this, size).pos = 1.Vector2s;

		arrow.action(&popup);
		arrow.move(POS_MIN, size.x + 1, POS_CENTER);

		toChildSize;
		pad(1);

		_arr = arr;
		_index = idx;

		if(idx >= 0)
		{
			select(idx);
		}
	}

	~this()
	{
		if(_pop)
		{
			_pop.deattach;
		}
	}

	override void onResize()
	{
		arrow.moveX(POS_MAX, -1);
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n, Vector2s(size.x, 1), borderColor);
		drawQuad(n + Vector2s(0, 1), Vector2s(1, size.y - 1), borderColor);
		drawQuad(n + Vector2s(1, size.y - 1), Vector2s(size.x - 1, 1), borderColor);
		drawQuad(n + Vector2s(size.x - 1, 1), Vector2s(1, size.y - 2), borderColor);

		drawQuad(n + Vector2s(arrow.pos.x - 1, 1), Vector2s(1, size.y - 2), borderColor);
		drawQuad(n + Vector2s(arrow.pos.x, 1), Vector2s(arrow.size.x, size.y - 2), Color(200, 200, 200, 128));

		super.draw(p);
	}

	@property elements()
	{
		return _arr[];
	}

	void delegate(int) onChange;
private:
	mixin publicProperty!(int, `index`);
	mixin MakeChildRef!(GUIImage, `arrow`, 0);

	const elemSize()
	{
		return Vector2s(arrow.pos.x - 2, size.y - 2);
	}

	void select(int idx)
	{
		if(_index >= 0)
		{
			_arr[_index].deattach;
		}

		if(_pop)
		{
			_pop = null;
			_arr.each!(a => a.deattach);
		}

		if(idx >= 0)
		{
			_arr[idx].attach(childs.back);
		}

		_index = idx;
	}

	void popup()
	{
		assert(!_pop);
		_pop = new SelectPopup(this);
	}

	SelectPopup _pop;
	RCArray!GUIElement _arr;
}

private:

class SelectPopup : Selector
{
	this(SelectBox box)
	{
		super(PE.gui.root);

		_box = box;
		_idx = box.index;

		box.select(-1);
		auto s = new Scrolled(this, box.elemSize, cast(ushort)min(box.elements.length, 8));

		s.pos.x = 1;

		foreach(i, c; box.elements)
		{
			auto v = allocateRC!Selectable(null);

			v.size = box.elemSize;
			v.idx = cast(int)i;
			c.attach(v);

			s.add(v, true);
		}

		pos = Vector2s(box.absPos.x, box.absEnd.y);
		size = Vector2s(s.size.x + 2, s.size.y + 1);

		focus;
	}

	~this()
	{
		_box.select(_idx);
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n, Vector2s(1, size.y), borderColor);
		drawQuad(n + Vector2s(1, size.y - 1), Vector2s(size.x - 1, 1), borderColor);
		drawQuad(n + Vector2s(size.x - 1, 0), Vector2s(1, size.y - 1), borderColor);

		drawQuad(n + Vector2s(1, 0), Vector2s(size.x - 2, size.y - 1));

		super.draw(p);
	}

	override void onFocus(bool v)
	{
		if(!v)
		{
			deattach;
		}
	}

	override void select(int idx)
	{
		_idx = idx;

		if(_box.onChange)
		{
			_box.onChange(idx);
		}

		deattach;
	}

private:
	mixin MakeChildRef!(Scrolled, `scroll`, 0);

	int _idx;
	SelectBox _box;
}
