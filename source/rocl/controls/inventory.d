module rocl.controls.inventory;

import std.meta, std.conv, std.range, std.string, std.algorithm, perfontain,

	ro.db, ro.conv, ro.conv.gui, ro.conv.item, rocl, rocl.gui.misc, rocl.game,
	rocl.paths, rocl.status, rocl.status.helpers, rocl.network, rocl.controls;

struct WinInventory
{
	void draw()
	{
		if (auto win = Window(MSG_INVENTORY, nk_rect(0, 0, 350, 150)))
		{
			drawSelector;
			drawTab;
		}
	}

private:
	mixin NuklearBase;

	void drawSelector()
	{
		auto tabs = [MSG_ITM, MSG_EQP, MSG_ETC];

		auto zeny = RO.status.param(SP_ZENY).value;
		auto weight = RO.status.param(SP_WEIGHT).value / 100;
		auto maxWeight = RO.status.param(SP_MAXWEIGHT).value / 100;

		auto s = format(`%s Z, %s: %u / %u`, price(zeny), MSG_WEIGHT, weight, maxWeight); // TODO: Ƶ

		nk.tabSelector(tabs, _tab, (ref a) => a.variable(widthFor(s)),
				() => nk.label(s, NK_TEXT_RIGHT));
	}

	void drawTab()
	{
		auto s1 = Style(&ctx.style.window.spacing, nk_vec2(0, 0));

		enum SZ = 36;
		nk.layout_row_static(SZ, SZ, nk.maxColumns(SZ));

		foreach (e; RO.status.items.arr[].filter!(a => a.tab == _tab))
		{
			scope r = new ItemIcon(e);
			r.draw;
		}
	}

	ubyte _tab;
}
