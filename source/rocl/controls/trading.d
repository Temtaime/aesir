module rocl.controls.trading;

import
		std.conv,
		std.ascii,

		perfontain,

		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.controls.status.equip;


final:

class WinTrading : WinBasic2
{
	this()
	{
		super(MSG_DEALING_WITH, `trading`);

		auto e = new TradingPart(main);
		/*{
			auto ok = new Button(this, BTN_PART, `OK`);
			ok.move(this, POS_MIN, 5, this, POS_MAX, -(WIN_BOTTOM_SZ.y - ok.size.y) / 2);
		}*/

		main.toChildSize;
		main.size += Vector2s(4);

		adjust;
	}

private:
	mixin MakeChildRef!(TradingPart, `src`, 0);
	mixin MakeChildRef!(TradingPart, `dst`, 1);
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
}
