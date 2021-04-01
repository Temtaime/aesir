module rocl.controls.shops;
import std.math, std.meta, std.conv, std.ascii, std.range, std.stdio,
	std.string, std.algorithm, perfontain, ro.db, ro.conv, ro.conv.gui,
	ro.conv.item, rocl, rocl.game, rocl.paths, rocl.status,
	rocl.status.helpers, rocl.network, rocl.controls, perfontain: Group;

auto price(uint p)
{
	string s;

	if (p < 1000)
	{
		return p.to!string;
	}

	while (true)
	{
		s ~= `k`;

		auto n = p / 1000;

		if (n < 1000)
		{
			auto u = p.to!string[$ - 3];
			return n.to!string ~ (u == '0' ? null : `.` ~ u) ~ s;
		}
		else
		{
			p = n;
		}
	}
}

final class WinShop : RCounted
{
	this(uint id)
	{
		ROnet.shopType(_id = id, 0);
	}

	void draw()
	{
		auto sz = Vector2s(350, 400);
		auto pos = (PE.window.size - sz) / 2;

		auto flags = Window.DEFAULT_FLAGS & ~NK_WINDOW_MINIMIZABLE | NK_WINDOW_CLOSABLE;

		if (auto win = Window(nk, MSG_TRADING, nk_rect(pos.x, pos.y, sz.x, sz.y), flags))
		{
			drawSelector;

			{
				auto height = nk.usableHeight - (nk.rowHeight + nk.ctx.style.window.spacing.y) * 2;
				nk.layout_row_dynamic(height, 1);

				if (auto group = Group(nk, nk.uniqueId))
					drawTab;
			}

			drawFooter;
		}

		if (nk.window_is_hidden(MSG_TRADING.toStringz)) // TODO: WHY NOT CLOSED ???
		{

			ROnet.closeShop;
			RO.gui.shop = null; // SIC: destroy self
		}
	}

	void buy(PkItemBuy[] arr)
	{
		_items = arr.map!(a => new Item(a)).array;
	}

	void sell(PkItemSell[] arr)
	{
		_items = arr.map!(a => RO.status.items.getIdx(a.idx)).array;

		foreach (idx, m; _items)
			m.price = max(arr[idx].price, arr[idx].overchargePrice); // TODO: IS IT LEGAL TO UPDATE INVENTORY ITEM'S PRICE ?
	}

private:
	mixin Nuklear;

	void drawFooter()
	{
		auto msg = _tab ? MSG_SELL : MSG_BUY;

		with (LayoutRowTemplate(nk, 0))
		{
			dynamic;
			static_(nk.buttonWidth(msg));
		}

		auto p = _items[].map!(a => a.price * a.shopAmount).sum;

		auto z = RO.status.param(SP_ZENY).value;
		auto color = _tab || p <= z ? `00ff00` : `ff0000`;

		auto s = format(`^ffffff%s : ^%s%s Z`, MSG_TOTAL, color, price(p)).colorSplit; // TODO: Ƶ, REMOVE EXPLICIT WHITE

		nk.coloredText(s);

		if (nk.button(msg))
		{
			auto arr = _items[].filter!(a => a.shopAmount);

			if (_tab)
				ROnet.shopSell(arr.map!(a => PkToSell(a.idx, cast(ushort)a.shopAmount)).array);
			else
				ROnet.shopBuy(arr.map!(a => PkToBuy(cast(ushort)a.shopAmount, a.id)).array);
		}
	}

	void drawSelector()
	{
		auto tabs = [MSG_BUYING, MSG_SELLING];

		if (nk.tabSelector(tabs, _tab))
			ROnet.shopType(_id, _tab);
	}

	void drawTab()
	{
		with (LayoutRowTemplate(nk, 36))
		{
			static_(36);
			dynamic();
			static_(80);
		}

		foreach (m; _items)
		{
			scope drawer = new ItemIcon(m);
			drawer.draw;

			auto s = m.data.name ~ ':';
			auto max = m.source == ITEM_SHOP ? 30_000 : m.amount;
			nk.property_int(s.toStringz, 0, &m.shopAmount, max, 1, 1);

			nk.label(format(`x %s Z`, price(m.price)), NK_TEXT_CENTERED); // TODO: Ƶ
		}
	}

	uint _id;
	ubyte _tab;

	RCArray!Item _items;
}
