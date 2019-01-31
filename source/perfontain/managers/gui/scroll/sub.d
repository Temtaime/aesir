module perfontain.managers.gui.scroll.sub;

import
		std.array,
		std.algorithm,

		perfontain;


final class Subscroll : GUIElement
{
	this(GUIElement p, Scrolled sc, uint id)
	{
		super(p);

		_sc = sc;
		flags.moveable = true;

		// top
		auto m = new GUIImage(this, id);
		//m.flags.background = true;

		size = Vector2s(m.size.x, m.size.y * 2);

		// middle
		{
			auto v = new GUIImage(this, id + 1);

			v.size.y = 0;
			v.pos.y = m.size.y;
			//v.flags.background = true;
		}

		// bottom
		m = new GUIImage(this, id, DRAW_MIRROR_V);

		m.pos.y = m.size.y;
		//m.flags.background = true;
	}

	void height(ushort n)
	{
		auto b = childs.back;
		auto d = b.size.y * 2;

		n = cast(ushort)max(0, n - d);

		childs[1].size.y = n;

		b.pos.y = cast(short)(b.size.y + n);
		size.y = cast(short)(d + n);
	}

	override void onMove() // TODO: HAS MOUSE FLAG ???
	{
		auto
				u = pos.y,
				v = size.y;

		/*with(_sc)
		{
			auto r = holderHeight - v;
			assert(u <= r);

			_idx = maxIndex * u / r;
			showElements;
		}*/

		//update;
	}

	void update()
	{
		//pos.y = cast(short)(_sc._idx * (_sc.holderHeight - size.y) / _sc.maxIndex);
	}

private:
	Scrolled _sc;
}
