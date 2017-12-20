module perfontain.managers.gui.select.box;

import
		std.array,
		std.algorithm,

		perfontain;


immutable borderColor = Color(200, 200, 200, 255);

final:

class SelectBox : GUIElement
{
	this(GUIElement p, GUIElement[] arr, ushort id, ushort sid, ushort w, short idx = -1)
	{
		assert(arr.length);

		_sid = sid;
		_arr = arr;

		size = Vector2s(w, arr[0].size.y + 2);

		{
			auto i = new GUIImage(this, id);

			i.onClick = &doPopup;
			i.pos = Vector2s(size.x - i.size.x - 2, (size.y - i.size.y - 1) / 2);
		}

		arr.each!(a => a.pos.x = 1);

		if(idx >= 0)
		{
			select(idx);
		}

		super(p);
	}

	~this()
	{
		if(_pop)
		{
			_pop.deattach;
		}
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n, Vector2s(size.x, 1), borderColor);
		drawQuad(n + Vector2s(0, 1), Vector2s(1, size.y - 1), borderColor);
		drawQuad(n + Vector2s(1, size.y - 1), Vector2s(size.x - 1, 1), borderColor);
		drawQuad(n + Vector2s(size.x - 1, 1), Vector2s(1, size.y - 2), borderColor);

		auto w = childs.front;

		drawQuad(n + Vector2s(w.pos.x - 2, 1), Vector2s(1, size.y - 2), borderColor);
		drawQuad(n + Vector2s(w.pos.x, 2), Vector2s(w.size.x, size.y - 4), borderColor);

		super.draw(p);
	}

	void delegate(short) onChange;
private:
	mixin publicProperty!(short, `idx`, `-1`);

	const elemWidth()
	{
		return cast(ushort)(childs[0].pos.x - 3); // TODO: REWRITE ?
	}

	void select(ushort idx)
	{
		if(_idx >= 0)
		{
			childs.popBack;
		}

		auto e = new GUIElement(this);

		e.pos = Vector2s(1);
		e.childs ~= _arr[_idx = idx];
	}

	void doPopup()
	{
		if(!_pop)
		{
			_pop = new SelectPopup(this);
		}

		if(_idx >= 0)
		{
			_pop.toPos(_idx);
		}

		_pop.attach(PE.gui.root);

		_pop.focus;
		_pop.pos = absPos + Vector2s(0, size.y);
	}

	ushort _sid;
	RCArray!GUIElement _arr;

	RC!SelectPopup _pop;
}

private:

class PopupSelector : Selector
{
	this(SelectPopup p)
	{
		_p = p;
	}

	override void select(int idx)
	{
		with(_p)
		{
			auto v = cast(ushort)idx;
			_b.select(v);

			if(auto f = _b.onChange)
			{
				f(v);
			}

			focus(false);
		}
	}

private:
	SelectPopup _p;
}

class SelectPopup : GUIElement
{
	this(SelectBox b)
	{
		super(null);

		auto arr = b._arr[];
		auto s = new Scrolled(this, Vector2s(b.size.x - 3, b.size.y - 2), cast(ushort)min(arr.length, 4), b._sid);

		s.pos.x = 1;
		auto ps = new PopupSelector(this);

		foreach(uint i, c; arr)
		{
			auto v = allocateRC!SelectableItem(null, ps);

			v.size = Vector2s(b.elemWidth, c.size.y);
			v.idx = i;
			v.childs ~= c;

			s.add(v, true);
		}

		_b = b;
		size = Vector2s(b.size.x, s.size.y + 1);
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

	override void onFocus(bool b)
	{
		if(!b)
		{
			deattach;
		}
	}

	void toPos(int idx)
	{
		(cast(Scrolled)childs.front).toPos(cast(ushort)idx);
	}

private:
	SelectBox _b;
}
