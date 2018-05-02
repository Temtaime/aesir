module rocl.controls.base;

import
		std.utf,
		std.meta,
		std.conv,
		std.range,
		std.string,
		std.typecons,
		std.algorithm,
		std.functional,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv,
		ro.conv.gui,
		ro.conv.item,

		rocl.paths,

		rocl,
		rocl.game,
		rocl.status,
		rocl.status.helpers,
		rocl.controls,
		rocl.controls.status.equip,
		rocl.controls.status.stats,
		rocl.controls.status.bonuses,
		rocl.network.packets;


final:

class WinBase : WinBasic
{
	this()
	{
		{
			name = `base`;

			super(Vector2s(220, 108), MSG_CHARACTER, false); // TODO: FIX ROent.self.cleanName

			if(pos.x < 0)
			{
				pos.x = 0;
			}
		}

		{
			auto arr =
			[
				tuple(MSG_INV, [ SDLK_LALT, SDLK_e ], () => doShow(ROgui.inv)),
				tuple(MSG_EQP, [ SDLK_LALT, SDLK_q ], () => doShow(ROgui.status)),
				tuple(MSG_SK, [ SDLK_LALT, SDLK_s ], () => doShow(ROgui.skills)),
				tuple(MSG_OPTS, [ SDLK_LALT, SDLK_o ], () => doShow(ROgui.settings)),
			];

			Button e;

			foreach(i, v; arr)
			{
				auto b = new Button(this, BTN_PART, v[0], PE.fonts.small);
				auto d = v[2].toDelegate;

				b.onClick = d;
				b.pos = Vector2s(size.x - b.size.x - 3, WIN_TOP_SZ.y + i * (b.size.y + 2) + 2);

				if(!e || e.size.x < b.size.x)
				{
					e = b;
				}

				//PE.hotkeys.add(Hotkey(null, d, cast(uint[])v[1]));
			}

			foreach(v; childs[$ - arr.length..$])
			{
				v.pos.x = e.pos.x;
				v.size.x = e.size.x;
			}
		}

		auto z = 6;

		{
			auto
					u = new GUIStaticText(this, `HP`),
					v = new GUIStaticText(this, `SP`);

			auto x = max(u.size.x, v.size.x) + 2;
			auto pos = Vector2s(z, WIN_TOP_SZ.y + z);

			hp = new PercMeter(this);
			sp = new PercMeter(this);

			u.pos = pos + Vector2s(0, (hp.size.y - u.size.y) / 2);
			v.pos = pos + Vector2s(0, hp.size.y + 4);

			hp.pos = pos + Vector2s(x, 0);
			sp.pos = hp.pos + Vector2s(0, hp.size.y + 4);
		}

		{
			auto
					u = new GUIStaticText(this, MSG_BASE_LVL),
					v = new GUIStaticText(this, MSG_JOB_LVL);

			auto x = max(u.size.x, v.size.x) + 2;
			auto pos = Vector2s(z, sp.pos.y + sp.size.y + 4);

			base = new LevelMeter(this);
			job = new LevelMeter(this);

			u.pos = pos;
			v.pos = pos + Vector2s(0, base.size.y);

			base.pos = pos + Vector2s(x, 0);
			job.pos = base.pos + Vector2s(0, base.size.y);
		}
	}

	PercMeter
				hp,
				sp;

	LevelMeter	base,
				job;
private:
	static doShow(GUIElement e)
	{
		e.show(!e.visible);
		e.focus;
	}
}

class PercMeter : GUIElement
{
	this(GUIElement e)
	{
		super(e);

		auto b = new Meter(this);

		with(PE.fonts)
		{
			auto x = base.widthOf(`100%`);
			size = Vector2s(b.size.x + x, max(small.height + b.size.y, base.height));
		}

		b.onUpdate = &onUpdate;
	}

	@property value(uint v) { meter.value = v; }
	@property maxValue(uint v) { meter.maxValue = v; }
private:
	@property meter()
	{
		return cast(Meter)childs.front;
	}

	void onUpdate()
	{
		while(childs.length > 1)
		{
			childs.popBack;
		}

		auto x = meter.size.x;

		auto
				u = meter.value,
				v = meter.maxValue;

		auto e = new GUIStaticText(this, format(`%u / %u`, u, v), 0, PE.fonts.small);
		e.pos = Vector2s((x - e.size.x) / 2, size.y - e.size.y);

		e = new GUIStaticText(this, format(`%u%%`, v ? u * 100 / v : 0));
		e.pos = Vector2s(x + 2, (size.y - e.size.y) / 2);
	}
}

class LevelMeter : GUIElement
{
	this(GUIElement e)
	{
		super(e);

		auto b = new Meter(this, true);

		with(PE.fonts)
		{
			auto x = base.widthOf(`999`);

			size = Vector2s(b.size.x + x, base.height);
		}

		b.pos = Vector2s(0, (size.y - b.size.y) / 2);
		b.onUpdate = &onUpdate;
	}

	@property value(uint v) { meter.value = v; }
	@property maxValue(uint v) { meter.maxValue = v; }

	@property lvl(uint v)
	{
		while(childs.length > 1)
		{
			childs.popBack;
		}

		auto e = new GUIStaticText(this, v.to!string);
		e.pos.x = cast(short)(size.x - e.size.x);
	}

private:
	@property meter()
	{
		return cast(Meter)childs.front;
	}

	void onUpdate() {} // TODO: GET RID
}

class Meter : GUIElement
{
	this(GUIElement p, bool tip = false)
	{
		super(p);

		_tip = tip;
		size = Vector2s(80, 5);
	}

	override void draw(Vector2s p) const
	{
		if(maxValue)
		{
			if(auto n = size.x * value / maxValue)
			{
				drawQuad(p + pos, Vector2s(min(size.x, n), size.y), Color(120, 225, 80, 255));
			}
		}
	}

	override void onHover(bool st)
	{
		if(_tip && st)
		{
			new TextTooltip(format(`%s / %s`, price(value), price(maxValue)));
		}
	}

	mixin StatusValue!(uint, `value`, onUpdate);
	mixin StatusValue!(uint, `maxValue`, onUpdate);

	void delegate() onUpdate;
private:
	bool _tip;
}
