module perfontain.managers.gui.select.box;

import
		std,

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
		_selected = idx;

		if(idx >= 0)
		{
			select(idx);
		}
	}

	~this()
	{
		if(_pop)
		{
			_pop._box = null;
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
	mixin publicProperty!(int, `selected`);
	mixin MakeChildRef!(GUIImage, `arrow`, 0);

	const elemSize()
	{
		return Vector2s(arrow.pos.x - 2, size.y - 2);
	}

	void select(int idx)
	{
		if(_selected >= 0)
		{
			_arr[_selected].deattach;
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

		_selected = idx;
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
		_idx = box.selected;

		box.select(-1);

		auto q = new GUIQuad(this, colorWhite);
		auto s = new Scrolled(this, Vector2s(1, min(8, box.elements.length)), box.elemSize.y);

		foreach(i, c; box.elements)
		{
			auto v = new Selectable(null, cast(int)i);

			v.size = box.elemSize;
			c.attach(v);

			s.add(v);
		}

		size = q.size = Vector2s(box.size.x - 2, s.size.y);

		s.size.x = size.x;
		s.onResize;

		if(box.absEnd.y + size.y > parent.size.y)
		{
			pos = Vector2s(box.absPos.x, box.absPos.y - size.y + 1);
		}
		else
		{
			pos = Vector2s(box.absPos.x, box.absEnd.y - 1);
		}

		pos.x += 1;
		focus;
	}

	~this()
	{
		if(_box)
		{
			_box.select(_idx);
		}
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
