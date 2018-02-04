module rocl.controls.trading;

import
		std.conv,
		std.ascii,

		perfontain,

		ro.conv.gui,

		rocl,
		rocl.game,
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

		// resize
		main.toChildSize;
		main.pad(2.Vector2s);

		adjust;

		{
			auto e = new Button(bottom, BTN_PART, `OK`);
			e.move(bottom, POS_MIN, 5, bottom, POS_CENTER);
		}

		{
			auto e = new Button(bottom, BTN_PART, `Trade`);
			e.move(bottom, POS_CENTER, 0, bottom, POS_CENTER);
		}

		{
			auto e = new Button(bottom, BTN_PART, `Cancel`);
			e.move(bottom, POS_MAX, -5, bottom, POS_CENTER);
		}
	}

	void add(Item m)
	{
		auto sc = src.sc;
		auto e = new EquipSlot(null, m, sc.elemWidth);

		sc.add(e, true);
	}

private:
	mixin MakeChildRef!(TradingPart, `src`, 1, 0);
	mixin MakeChildRef!(TradingPart, `dst`, 1, 1);
}

class TradingPart : GUIElement
{
	this(GUIElement p)
	{
		super(p);

		new Scrolled(this, Vector2s(220, 36), 4, SCROLL_ARROW);

		{
			auto e = new GUIElement(this);

			auto t = new GUIStaticText(e, `Ƶ`);
			auto u = new Underlined(e);
			auto v = new GUIEditText(u);

			v.size.x = 80;

			v.onChar = (a)
			{
				if(a.length == 1 && a[0].isDigit)
				{
					if(to!long(v.value ~ a) <= int.max)
					{
						return true;
					}
				}

				return false;
			};

			u.update;
			u.moveX(t, POS_ABOVE, 10);

			e.toChildSize;
			e.move(sc, POS_MIN, 10, sc, POS_ABOVE, 2);
		}

		toChildSize;
	}

	mixin MakeChildRef!(Scrolled, `sc`, 0);
}
