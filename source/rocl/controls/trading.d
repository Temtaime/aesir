module rocl.controls.trading;

import
		std.conv,
		std.ascii,

		perfontain,

		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.status,
		rocl.status.item,
		rocl.controls.status.equip;


final:

class WinTrading : WinBasic2
{
	this()
	{
		super(MSG_DEALING_WITH, `trading`);

		new TradingPart(main);
		new TradingPart(main);

		dst.moveX(src, POS_ABOVE);
		adjust;

		{
			new Button(bottom, MSG_OK);
			ok.move(bottom, POS_MIN, 5, bottom, POS_CENTER);

			ok.onClick =
			{
				{
					auto v = src.zeny;

					src.zeny(v);
					ROnet.tradeItem(0, v);
				}

				ok.flags.enabled = false;
				ROnet.tradeAction(0);
			};
		}

		{
			new Button(bottom, MSG_TRADE);
			trade.move(bottom, POS_CENTER, 0, bottom, POS_CENTER);

			trade.onClick =
			{
				ROnet.tradeAction(1);
				trade.flags.enabled = false;
			};

			trade.flags.enabled = false;
		}

		{
			auto e = new Button(bottom, MSG_CANCEL);
			e.move(bottom, POS_MAX, -5, bottom, POS_CENTER);

			e.onClick =
			{
				ROnet.tradeAction(-1);
				e.flags.enabled = false;
			};
		}

		itemsSrc.onAdded.permanent(a => add(src.sc, a));
		itemsDst.onAdded.permanent(a => add(dst.sc, a));
	}

	void zeny(uint cnt)
	{
		dst.zeny(cnt);
	}

	void lock(bool self)
	{
		(self ? src : dst).locked = true;

		if(src.locked && dst.locked)
		{
			trade.flags.enabled = true;
		}
	}

	Items
			itemsSrc,
			itemsDst;
private:
	void add(Scrolled sc, Item m)
	{
		//auto e = new EquipSlot(null, m, sc.elemWidth);
		//sc.add(e, true);
	}

	mixin MakeChildRef!(TradingPart, `src`, 1, 0);
	mixin MakeChildRef!(TradingPart, `dst`, 1, 1);

	mixin MakeChildRef!(Button, `ok`, 2, 0);
	mixin MakeChildRef!(Button, `trade`, 2, 1);

	RCArray!Item _srcItems;
}

class TradingPart : GUIElement
{
	this(GUIElement p)
	{
		super(p);

		//new Scrolled(this, Vector2s(220, 36), 4);

		{
			auto e = new GUIElement(this);
			new Underlined(e);

			{
				new GUIEditText(und);

				edit.size.x = 80;
				edit.onChar = a => a.length == 1 && a[0].isDigit && to!long(edit.value ~ a) <= RO.gui.inv.zeny;

				und.update;
			}

			{
				auto t = new GUIStaticText(e, `Ƶ`);
				und.moveX(t, POS_ABOVE, 10);
			}

			e.toChildSize;
			e.move(sc, POS_MIN, 10, sc, POS_ABOVE, 2);
		}

		toChildSize;
		size.y += 4;
	}

	override void draw(Vector2s p) const
	{
		super.draw(p);

		if(locked)
		{
			drawQuad(p + pos, size, Color(128, 128, 128, 128)); // TODO: light gray
		}
	}

	void zeny(uint z)
	{
		und.childs.clear;

		auto e = new GUIStaticText(und, price(z));
		e.moveY(und, POS_MAX, -1);
	}

	auto zeny()
	{
		auto v = edit.value;
		return v.length ? edit.value.to!uint : 0;
	}

	bool locked;

	mixin MakeChildRef!(Scrolled, `sc`, 0);
private:
	mixin publicProperty!(uint, `zeny`);

	mixin MakeChildRef!(Underlined, `und`, 1, 0);
	mixin MakeChildRef!(GUIEditText, `edit`, 1, 0, 0);
}
