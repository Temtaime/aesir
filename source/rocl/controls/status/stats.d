module rocl.controls.status.stats;

import
		std.meta,
		std.conv,
		std.range,
		std.string,
		std.algorithm,

		perfontain,

		ro.conv.gui,

		rocl.status,
		rocl.controls;


final:

class StatsUpper : GUIStaticText
{
	this(GUIElement w)
	{
		super(w, `▲`, FONT_BOLD);

		flags = Win.none;
		color = Color(30, 33, 150, 255);
	}

	override void onPress(bool)
	{
		auto idx = cast(int)RO.gui
									.status
									.stats
									.childs[]
									.countUntil!(a => a.childs[].any!(b => b is this));

		assert(idx >= 0);
		ROnet.statsUp(cast(ushort)(SP_STR + idx));
	}
}

class StatsSlot : GUIElement
{
	this(GUIElement win, ushort w, string name, ushort value, ushort bonus, ushort cost)
	{
		auto sw = PE.fonts.base.widthOf(`_`, FONT_BOLD);

		{
			auto e = new GUIStaticText(this, name, FONT_BOLD);
			e.color = Color(30, 33, 150, 255);

			size = Vector2s(w, e.size.y + 1);
		}

		{
			auto e = new GUIStaticText(this, value.to!string ~ (bonus ? ` + ` ~ bonus.to!string : null));
			e.pos = Vector2s(sw * 4, 0);
		}

		if(cost)
		{
			sw *= 2;

			{
				auto e = new GUIStaticText(this, cost.to!string);
				e.pos = Vector2s(size.x - sw, 0);
			}

			{
				auto e = new StatsUpper(this);
				e.pos = Vector2s(size.x - sw - e.size.x, 0);
			}
		}

		super(win);
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n + Vector2s(0, size.y - 1), Vector2s(size.x, 1), Color(128, 128, 128, 200));

		super.draw(p);
	}
}

class StatsView : GUIElement
{
	this(GUIElement win, ushort w)
	{
		super(win);

		foreach(i, s; Stats)
		{
			auto v = &RO.status.stats[i];
			auto e = new StatsSlot(this, w, s, v.base, v.bonus, v.needs);

			e.pos.y = size.y;
			size.y += e.size.y;
		}

		size.x = w;
	}

	void update(ref in Stat s)
	{
		{
			auto idx = s.idx;
			auto e = new StatsSlot(null, size.x, Stats[idx], s.base, s.bonus, s.needs);

			e.pos = childs[idx].pos;
			e.parent = this;

			childs[idx] = e;
		}

		PE.gui.updateMouse;
	}

private:
	static immutable Stats =
	[
		`STR`, `AGI`, `VIT`, `INT`, `DEX`, `LUK`
	];
}
