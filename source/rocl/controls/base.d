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

class WinBase : WinBasic2
{
	this()
	{
		{
			super(MSG_CHARACTER, `base`); // TODO: FIX ROent.self.cleanName

			if(pos.x < 0)
			{
				pos.x = 0;
			}
		}

		auto w1 = new GUIElement(main);
		auto w2 = new GUIElement(main);

		{
			auto hp = new InfoMeter(w1, `HP`);
			auto sp = new InfoMeter(w1, `SP`);

			sp.moveY(hp, POS_ABOVE);
			w1.toChildSize;

			hp.moveX(POS_MAX);
			sp.moveX(POS_MAX);
		}

		w2.moveY(w1, POS_ABOVE);

		{
			auto bl = new InfoMeter(w2, MSG_BASE_LVL);
			auto jl = new InfoMeter(w2, MSG_JOB_LVL);

			jl.moveY(bl, POS_ABOVE);
			w2.toChildSize;

			bl.moveX(POS_MAX);
			jl.moveX(POS_MAX);
		}

		{
			auto arr =
			[
				tuple(MSG_INV, () => RO.gui.inv.showOrHide),
				tuple(MSG_EQP, () => RO.gui.status.showOrHide),
				tuple(MSG_SK, () => RO.gui.skills.showOrHide),
				tuple(MSG_OPTS, () => RO.gui.settings.showOrHide),
			];

			auto e = new Table(main, 1);

			arr.each!(a => e.add(new Button(null, a[0], a[1].toDelegate)));
			e.adjust;

			e.moveX(w2, POS_ABOVE, 4);
		}

		/*{
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
		}*/




		adjust;

		/*auto z = 6;



		{
			auto
					u = new GUIStaticText(this, ),
					v = new GUIStaticText(this, );

			auto x = max(u.size.x, v.size.x) + 2;
			auto pos = Vector2s(z, sp.pos.y + sp.size.y + 4);

			base = new LevelMeter(this);
			job = new LevelMeter(this);

			u.pos = pos;
			v.pos = pos + Vector2s(0, base.size.y);

			base.pos = pos + Vector2s(x, 0);
			job.pos = base.pos + Vector2s(0, base.size.y);
		}*/
	}

	/*PercMeter
				hp,
				sp;

	LevelMeter	base,
				job;*/
}

class InfoMeter : GUIElement
{
	this(GUIElement p, string s)
	{
		super(p);

		auto e = new GUIStaticText(this, s);

		new class GUIQuad
		{
			this()
			{
				super(this.outer, Color(200, 200, 200, 255));

				flags.captureFocus = true;
			}

			override void onHover(bool st)
			{
				if(st)
				{
					new TextTooltip(format(`%u / %u`, value, maxValue));
				}
			}
		};

		bg.size = BAR_SIZE + Vector2s(2);
		bg.moveX(e, POS_ABOVE, 4);

		new GUIQuad(this, Color(120, 225, 80, 255));
		proc.move(bg, POS_MIN, 1, bg, POS_MIN, 1);

		{
			auto r = new GUIElement(this, Vector2s(0, PE.fonts.small.height));
			r.moveY(bg, POS_ABOVE);
		}

		toChildSize;
		onUpdate;

		e.moveY(POS_CENTER);
	}

	mixin StatusValue!(uint, `value`, onUpdate);
	mixin StatusValue!(uint, `maxValue`, onUpdate);
private:
	enum BAR_SIZE = Vector2s(80, 5);

	mixin MakeChildRef!(GUIQuad, `bg`, 1);
	mixin MakeChildRef!(GUIQuad, `proc`, 2);

	void onUpdate()
	{
		if(auto n = maxValue ? ulong(BAR_SIZE.x) * min(value, maxValue) / maxValue : 0)
		{
			proc.flags.hidden = false;
			proc.size = Vector2s(n, BAR_SIZE.y);
		}
		else
		{
			proc.flags.hidden = true;
		}

		childs.popBack;

		auto e = new GUIStaticText(this, format(`%s / %s`, price(value), price(maxValue)), 0, PE.fonts.small);
		e.move(bg, POS_CENTER, 0, bg, POS_ABOVE);
	}
}
