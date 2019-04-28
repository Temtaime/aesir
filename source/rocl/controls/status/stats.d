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
		FontInfo fi =
		{
			flags: FONT_BOLD
		};

		super(w, `▲`, fi);

		flags = Win.none;
		color = Color(30, 33, 150, 255);
	}

	override void onPress(Vector2s, bool)
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
	this(GUIElement p, ushort w, string name, ushort value, ushort bonus, ushort cost)
	{
		super(p);

		FontInfo fi =
		{
			flags: FONT_BOLD
		};

		auto sw = PE.fonts.base.widthOf(`_`, FONT_BOLD);

		{
			auto e = new GUIStaticText(this, name, fi);
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
	this(GUIElement p, ushort w)
	{
		super(p);

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
