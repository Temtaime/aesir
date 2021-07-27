module rocl.controls.storage.inventory;
import std.meta, std.conv, std.range, std.string, std.algorithm, perfontain, ro.db, ro.conv, ro.conv.gui, ro.conv.item,
	rocl, rocl.gui.misc, rocl.game, rocl.paths, rocl.status, rocl.status.helpers, rocl.network, rocl.controls,
	rocl.controls.storage, rocl.controls.storage;

final class WinInventory : ItemView
{
	void draw()
	{
		if (auto win = Window(nk, MSG_INVENTORY, nk_rect(0, 0, 350, 150)))
		{
			drawImpl;
		}
	}

protected:
	override string info()
	{
		auto zeny = RO.status.param(SP_ZENY).value;
		auto weight = RO.status.param(SP_WEIGHT).value / 100;
		auto maxWeight = RO.status.param(SP_MAXWEIGHT).value / 100;

		return format(`%s Z, %s: %u / %u`, price(zeny), MSG_WEIGHT, weight, maxWeight); // TODO: Ƶ
	}

	override Item[] items()
	{
		return RO.status.items.arr[];
	}

	override void onIconDraw(in Widget w, Item m)
	{
		if (w.clicked(NK_BUTTON_LEFT))
		{
			if (RO.gui.kafra.isActive)
			{
				ROnet.storePut(m.idx, m.amount);
			}
			else
			{
				m.action;
			}
		}
	}
}
