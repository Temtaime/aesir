module rocl.controls.shops;

import
		std.math,
		std.meta,
		std.conv,
		std.ascii,
		std.range,
		std.stdio,
		std.string,
		std.algorithm,

		perfontain,

		ro.db,
		ro.conv,
		ro.conv.gui,
		ro.conv.item,

		rocl,
		rocl.game,
		rocl.paths,
		rocl.status,
		rocl.status.helpers,
		rocl.network,
		rocl.controls,
		rocl.controls.status.equip;


auto price(uint p)
{
	string s;

	if(p < 1000)
	{
		return p.to!string;
	}

	while(true)
	{
		s ~= `k`;

		auto n = p / 1000;

		if(n < 1000)
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

final class WinShop : WinBasic
{
	this(uint id)
	{
		_id = id;

		{
			name = `shop`;
			super(Vector2s(290, 360), MSG_TRADING);
		}

		{
			GUIElement[] arr;

			foreach(u; only(MSG_BUYING, MSG_SELLING))
			{
				arr ~= new GUIStaticText(null, u);
			}

			_se = new SelectBox(this, arr, 0);
			_se.move(this, POS_MIN, 4, this, POS_MAX, (_se.size.y - WIN_BOTTOM_SZ.y) / 2);

			_se.onChange = &retype;
		}

		retype(0);
	}

	void make(T)(in T[] items)
	{
		enum Buy = is(T == PkItemBuy);

		while(childs.back !is _se)
		{
			childs.popBack;
		}

		/*{
			auto ty = WIN_TOP_SZ.y;
			_sc = new Scrolled(this, Vector2s(size.x - 4, 36), cast(ushort)(size.y - ty - WIN_BOTTOM_SZ.y - 4) / 36);

			_sc.pos = Vector2s(2, ty + 2);

			static if(Buy)
			{
				auto arr = items.map!(a => new Item(a)).array;
			}
			else
			{
				auto arr = items.map!(a => RO.status.items.getIdx(a.idx));

				foreach(m, e; zip(arr, items))
				{
					m.price = max(e.price, e.overchargePrice);
				}
			}

			auto ps = arr.map!(a => price(a.price)).array;
			auto priceW = cast(ushort)ps.fold!((a, b) => max(PE.fonts.base.widthOf(b), a))(0);

			foreach(i; items.length.iota)
			{
				//_sc.add(new ShopRow(this, arr[i], ps[i], priceW, _sc.elemWidth), true);
			}
		}*/

		auto b = new Button(this, Buy ? MSG_BUY : MSG_SELL);
		b.move(this, POS_MAX, -4, this, POS_MAX, (b.size.y - WIN_BOTTOM_SZ.y) / 2);
		b.onClick = &onClick;

		reprice;
	}

	void reprice()
	{
		if(cast(GUIStaticText)childs.back)
		{
			childs.popBack;
		}

		auto p = items.fold!((a, b) => a + b.num.value * b.item.price)(0);
		auto e = new GUIStaticText(this, format(`%s : %s Ƶ`, MSG_TOTAL, price(p)));

		e.move(_se, POS_ABOVE, 4, this, POS_MAX, (e.size.y - WIN_BOTTOM_SZ.y) / 2);
	}

private:
	void retype(int n)
	{
		ROnet.shopType(_id, cast(ubyte)n);
	}

	ShopRow[] items()
	{
		return null; //_sc.rows[].map!(a => cast(ShopRow)a).filter!(a => !!a.num.value);
	}

	const buying()
	{
		return !_se.selected;
	}

	void onClick()
	{
		if(buying)
		{
			PkToBuy[] arr;

			foreach(e; items)
			{
				arr ~= PkToBuy(cast(ushort)e.num.value, e.item.id);
			}

			ROnet.shopBuy(arr);
		}
		else
		{
			PkToSell[] arr;

			foreach(e; items)
			{
				arr ~= PkToSell(e.item.idx, cast(ushort)e.num.value);
			}

			ROnet.shopSell(arr);
		}
	}

	uint _id;
	Scrolled _sc;
	SelectBox _se;
}

final class ShopRow : GUIElement
{
	this(WinShop shop, Item m, string ps, ushort pw, ushort w)
	{
		super(null);

		item = m;
		size = Vector2s(w, 36);

		check = new CheckBox(this);

		{
			check.move(this, POS_MIN, 4, this, POS_CENTER);

			check.onChange = (a)
			{
				if(a)
				{
					num.set(m.source == ITEM_SHOP ? 1 : m.amount); // equip
					num.focus;
				}
				else
				{
					num.clear;
				}
			};
		}

		num = new NumEdit(this);

		{
			num.size.x = cast(ushort)(PE.fonts.base.widthOf(`_`) * 5);
			num.move(this, POS_MAX, -4, this, POS_MAX);

			num.onEdit = (a)
			{
				check.checked = !!a;
				shop.reprice;
			};

			num.maxValue = m.source == ITEM_SHOP ? 30_000 : m.amount; // equip
		}

		auto x = new GUIStaticText(this, `x`);
		x.move(num, POS_BELOW, -4, this, POS_MAX);

		auto p = new GUIElement(this);

		{
			p.size = Vector2s(pw + 8, 36);
			p.moveX(x, POS_BELOW);

			auto t = new GUIStaticText(p, ps);
			t.move(p, POS_CENTER, 0, p, POS_MAX, -1);
		}

		auto r = new EquipSlot(this, m, cast(ushort)(p.pos.x - check.end.x - 4));
		r.moveX(check, POS_ABOVE, 4);
	}

	NumEdit num;
	CheckBox check;

	RC!Item item;
}

final class NumEdit : GUIEditText
{
	this(GUIElement e)
	{
		super(e);

		size.y += 1;
	}

	override void onText(string s)
	{
		if(s.all!isDigit)
		{
			super.onText(s);
		}
	}

	override void draw(Vector2s p) const
	{
		super.draw(p);

		drawQuad(p + pos + Vector2s(0, size.y - 1), Vector2s(size.x, 1), Color(128, 128, 128, 200));
	}

	void set(uint v)
	{
		value = min(v, maxValue);
		_text = value ? value.to!string : null;

		if(onEdit)
		{
			onEdit(value);
		}

		super.update;
	}

	uint
			value,
			maxValue;

	void delegate(uint) onEdit;
protected:
	override void update()
	{
		set(_text.length ? _text.to!uint : 0);
	}
}
