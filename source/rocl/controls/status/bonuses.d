module rocl.controls.status.bonuses;

import
		std.meta,
		std.conv,
		std.range,
		std.string,

		perfontain,

		ro.conv.gui,

		rocl.status,
		rocl.controls;


final:

class BonusesSlot : GUIElement
{
	this(GUIElement p, ushort w, string name, ushort value, ushort value2)
	{
		super(p);

		{
			FontInfo fi =
			{
				flags: FONT_BOLD
			};

			auto e = new GUIStaticText(this, name, fi);

			e.color = Color(30, 33, 150, 255);

			size = Vector2s(w, e.size.y + 1);
		}

		{
			auto e = new GUIStaticText(this, value.to!string ~ (value2 ? ` + ` ~ value2.to!string : null));

			e.pos = Vector2s(size.x - e.size.x, 0);
		}
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n + Vector2s(0, size.y - 1), Vector2s(size.x, 1), Color(128, 128, 128, 200));

		super.draw(p);
	}
}

class BonusesView : GUIElement
{
	this(GUIElement p, ushort w)
	{
		super(p);

		size.x = w;

		foreach(i, s; Bonuses)
		{
			auto v = &RO.status.bonuses[i];
			auto e = new BonusesSlot(this, cast(ushort)(bonusWidth + (i > 3 ? -10 : 10)), s, v.base, v.base2);

			e.pos = Vector2s(i > 3 ? e.size.x + 30 : 0, i % 4 * e.size.y);
		}

		size.y = cast(ushort)(childs.back.size.y * 4);
	}

	void update(ref in Bonus b)
	{
		auto idx = b.idx;
		auto e = new BonusesSlot(null, childs[idx].size.x, Bonuses[idx], b.base, b.base2);

		e.pos = childs[idx].pos;
		e.parent = this;

		childs[idx] = e;
	}

private:
	static immutable Bonuses =
	[
		`ATK`, `MATK`, `HIT`, `CRIT`, `DEF`, `MDEF`, `FLEE`, `ASPD`
	];

	const bonusWidth()
	{
		return cast(ushort)(size.x / 2 - 5);
	}
}
