module rocl.controls.trading;

import
		perfontain,

		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.controls.status.equip;


final:

class WinTrading : WinBasic
{
	this()
	{
		auto e = new TradingPart(this);
		e.pos = Vector2s(0, WIN_TOP_SZ.y + 2);

		name = `trading`;
		super(Vector2s(360, e.end.y + WIN_BOTTOM_SZ.y + 2), MSG_DEALING_WITH);
	}
}

class TradingPart : GUIElement
{
	this(GUIElement p)
	{
		super(p);

		auto sc = new Scrolled(this, Vector2s(180, 36), 4, SCROLL_ARROW);

		foreach(i; 0..5)
		{
			auto e = new EquipSlot(null, RO.status.items.arr[i], sc.elemWidth);
			sc.add(e, true);
		}

		auto t = new GUIStaticText(this, `Ƶ`);
		t.moveY(sc, POS_ABOVE);

		size = Vector2s(180, 4 * 36 + t.size.y);
	}
}
