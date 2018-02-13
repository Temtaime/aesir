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

		main.toChildSize;
		main.pad(2);

		adjust;

		{
			new Button(bottom, BTN_PART, MSG_OK);
			ok.move(bottom, POS_MIN, 5, bottom, POS_CENTER);

			ok.onClick =
			{
				ROnet.tradeAction(0);
			};
		}

		{
			new Button(bottom, BTN_PART, `Trade`);
			trade.move(bottom, POS_CENTER, 0, bottom, POS_CENTER);

			trade.onClick =
			{
				ROnet.tradeAction(1);
			};

			trade.enabled = false;
		}

		{
			auto e = new Button(bottom, BTN_PART, MSG_CANCEL);
			e.move(bottom, POS_MAX, -5, bottom, POS_CENTER);

			e.onClick =
			{
				ROnet.tradeAction(-1);
			};
		}

		items.onAdded.permanent(&add);
	}

	void zeny(uint cnt, bool self)
	{

	}

	void lock(bool self)
	{
		if(self)
		{
			//src.lock;
			ok.enabled = false;
		}
		else
		{
			//dst.lock();
		}

		if(src.locked && dst.locked)
		{
			trade.enabled = true;
		}
	}

	Items items;
private:
	void add(Item m)
	{
		auto sc = dst.sc;
		auto e = new EquipSlot(null, m, sc.elemWidth);

		sc.add(e, true);
	}

	mixin MakeChildRef!(TradingPart, `src`, 1, 0);
	mixin MakeChildRef!(TradingPart, `dst`, 1, 1);

	mixin MakeChildRef!(Button, `ok`, 2, 0);
	mixin MakeChildRef!(Button, `trade`, 2, 1);
}

class TradingPart : GUIElement
{
	this(GUIElement p)
	{
		super(p);

		new Scrolled(this, Vector2s(220, 36), 4, SCROLL_ARROW);

		{
			auto e = new GUIElement(this);
			new Underlined(e);

			{
				auto v = new GUIEditText(und);

				v.size.x = 80;
				v.onChar = a => a.length == 1 && a[0].isDigit && to!long(v.value ~ a) <= ROgui.inv.zeny;

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

	void lock(uint z)
	{
	}

	mixin MakeChildRef!(Scrolled, `sc`, 0);
private:
	mixin publicProperty!(bool, `locked`);

	mixin MakeChildRef!(Underlined, `und`, 1, 0);
}
