module rocl.controls.base;

import std.utf, std.meta, std.conv, std.range, std.string, std.typecons,
	std.algorithm, std.functional, perfontain, perfontain.opengl, ro.grf,
	ro.conv, ro.conv.gui, ro.conv.item, rocl.paths, rocl, rocl.game,
	rocl.status, rocl.status.helpers, rocl.controls, rocl.network.packets;

final:

class WinBase //: GUIWindow
{
	this()
	{
		//super(MSG_CHARACTER, Vector2s(200)); // TODO: FIX ROent.self.cleanName

		/*auto w1 = new GUIElement(main);
		auto w2 = new GUIElement(main);

		{
			auto hp = new InfoMeter(w1, `HP`);
			auto sp = new InfoMeter(w1, `SP`);

			RO.status.hp.onChange.permanent(a => hp.value = a);
			RO.status.maxHp.onChange.permanent(a => hp.maxValue = a);

			RO.status.sp.onChange.permanent(a => sp.value = a);
			RO.status.maxSp.onChange.permanent(a => sp.maxValue = a);

			sp.moveY(hp, POS_ABOVE);
			w1.toChildSize;

			hp.moveX(POS_MAX);
			sp.moveX(POS_MAX);
		}

		w2.moveY(w1, POS_ABOVE);

		{
			auto base = new InfoMeter(w2, MSG_BASE_LVL);
			auto job = new InfoMeter(w2, MSG_JOB_LVL);

			RO.status.blvl.onChange.permanent(a => base.misc = a);
			RO.status.bexp.onChange.permanent(a => base.value = a);
			RO.status.bnextExp.onChange.permanent(a => base.maxValue = a);

			RO.status.jlvl.onChange.permanent(a => job.misc = a);
			RO.status.jexp.onChange.permanent(a => job.value = a);
			RO.status.jnextExp.onChange.permanent(a => job.maxValue = a);

			job.moveY(base, POS_ABOVE);
			w2.toChildSize;

			base.moveX(POS_MAX);
			job.moveX(POS_MAX);
		}

		{
			auto arr =
			[
				tuple(MSG_INV, () => RO.gui.inv.showOrHide),
				tuple(MSG_EQP, () => RO.gui.status.showOrHide),
				tuple(MSG_SK, () => RO.gui.skills.showOrHide),
				tuple(MSG_OPTS, () => RO.gui.settings.showOrHide),
			];

			auto t = new Table(main, Vector2s(1, 0));

			arr.each!(a => t.add(new Button(null, a[0], a[1].toDelegate)));

			t.childs.each!(a => a.childs[0].toParentSize);
			t.moveX(w2, POS_ABOVE, 4);
		}

		adjust;*/
	}
}

class InfoMeter// : GUIElement
{
	//this(GUIElement p, string s)
	//{
		// super(p);

		// auto e = new GUIStaticText(this, s);

		// new class GUIQuad
		// {
		// 	this()
		// 	{
		// 		super(this.outer, Color(200, 200, 200, 255));

		// 		flags.captureFocus = true;
		// 	}

		// 	override void onHover(bool st)
		// 	{
		// 		if(st)
		// 		{
		// 			new TextTooltip(format(`%u / %u`, value, maxValue));
		// 		}
		// 	}
		// };

		// bg.size = BAR_SIZE + Vector2s(2);
		// bg.moveX(e, POS_ABOVE, 4);

		// new GUIQuad(this, Color(120, 225, 80, 255));
		// proc.move(bg, POS_MIN, 1, bg, POS_MIN, 1);

		// {
		// 	auto r = new GUIElement(this, Vector2s(0, PE.fonts.small.height));
		// 	r.moveY(bg, POS_ABOVE);
		// }

		// toChildSize;
		// onUpdate;

		// e.moveY(POS_CENTER);
	//}

	mixin StatusValue!(uint, `misc`, onUpdate);
	mixin StatusValue!(uint, `value`, onUpdate);
	mixin StatusValue!(uint, `maxValue`, onUpdate);
private:
	enum BAR_SIZE = Vector2s(80, 5);

	//mixin MakeChildRef!(GUIQuad, `bg`, 1);
	//mixin MakeChildRef!(GUIQuad, `proc`, 2);

	void onUpdate()
	{
		// if (auto n = maxValue ? ulong(BAR_SIZE.x) * min(value, maxValue) / maxValue : 0)
		// {
		// 	proc.flags.hidden = false;
		// 	proc.size = Vector2s(n, BAR_SIZE.y);
		// }
		// else
		// {
		// 	proc.flags.hidden = true;
		// }

		// //childs.popBack;

		// FontInfo fi = {font: PE.fonts.small};

		// auto e = new GUIStaticText(this, misc ? misc.to!string : format(`%s / %s`, price(value), price(maxValue)), fi);
		// e.move(bg, POS_CENTER, 0, bg, POS_ABOVE);
	}
}
