module perfontain.managers.gui.scroll.bar;

import
		std.experimental.all,

		perfontain;


final:

class Scrollbar : GUIElement
{
	this(Scrolled sc)
	{
		super(sc, Vector2s.init, Win.captureFocus);

		auto up = new GUIImage(this, SCROLL_ARROW);
		size = Vector2s(up.size.x, sc.size.y);

		auto down = new GUIImage(this, SCROLL_ARROW, DRAW_MIRROR_V);
		down.moveY(POS_MAX);

		up.action({ sc.onWheel(1.Vector2s); });
		down.action({ sc.onWheel(-1.Vector2s); });

		new class GUIElement
		{
			this()
			{
				super(this.outer, Vector2s.init, Win.captureFocus);

				poseBetween(up, down);
				new Scrollpart(this);
			}

			override void onPress(Vector2s p, bool v)
			{
				if(v)
				{
					part.pos.y = cast(short)clamp(p.y - part.size.y / 2, 0, size.y - part.size.y);
					part.onMoved;
				}
			}

			mixin MakeChildRef!(Scrollpart, `part`, 0);
		};
	}
}

class Scrollpart : GUIElement
{
	this(GUIElement p)
	{
		super(p, Vector2s.init, Win.moveable | Win.captureFocus);

		sc.onPosChanged.permanent(&pose);
		sc.onCountChanged.permanent(&update);

		update;
	}

	override void onMoved()
	{
		sc.pose((pos.y * sc.table.maxIndex + spacer - 1) / spacer);
	}

private:
	const spacer()
	{
		return parent.size.y - size.y;
	}

	void pose(uint n)
	{
		if(auto r = sc.table.maxIndex)
		{
			pos.y = cast(short)(spacer * n / r);
		}
	}

	void update()
	{
		childs.clear;

		auto up = new GUIImage(this, SCROLL_PART);
		auto down = new GUIImage(this, SCROLL_PART, DRAW_MIRROR_V);

		auto t = sc.table;
		auto h = parent.size.y - up.size.y * 2;

		if(t.maxIndex)
		{
			h = h * t.sz.y / t.rows;
		}

		if(h)
		{
			auto e = new GUIImage(this, SCROLL_SPACER);
			e.size.y = cast(short)h;
			e.moveY(up, POS_ABOVE);
		}

		down.moveY(childs.back, POS_ABOVE);
		toChildSize;
	}

	auto sc()
	{
		return firstParent!Scrolled;
	}
}
