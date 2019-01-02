module rocl.controls.inventory;

import
		std.meta,
		std.conv,
		std.range,
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
		rocl.controls;


final class InventoryTab : GUIElement
{
	this(GUIElement p, Vector2s sz)
	{
		super(p);

		foreach(i; 0..sz.x)
		foreach(j; 0..sz.y)
		{
			auto im = new GUIImage(this, INV_ITEM);

			im.flags.background = true;
			im.pos = Vector2s(INV_TAB_ITEM_SZ.x, 0) + Vector2s(i * 36, j * 36) + (Vector2s(36) - im.size) / 2;
		}

		auto w = sz.x * 36 + SCROLL_ARROW_SZ.x;
		auto m = sz.y > 2;

		size = Vector2s(INV_TAB_ITEM_SZ.x + w, sz.y * 36);

		{
			auto n = new TabWindow(this, cast(ushort)w, [ 24, 27, 29 ], INV_TAB_ITEM, m ? size.y : -1);

			foreach(i; 0..3)
			{
				new Scrolled(n.tabs[i], Vector2s(n.tab.size.x, 36), sz.y, SCROLL_ARROW);
			}

			if(!m)
			{
				size.y = n.size.y;
			}
		}
	}

	void register(Item m)
	{
		if(!m.equip2)
		{
			add(m);
		}

		if(m.equip)
		{
			m.onEquip.permanent(&remove);
			m.onUnequip.permanent(&add);
		}

		m.onRemove.permanent(&remove);
	}

private:
	void add(Item m)
	{
		add(_aa[m] = new ItemHolder(null, m), m.tab);
	}

	void remove(Item m)
	{
		if(auto p = m in _aa)
		{
			remove(*p, m.tab);
			_aa.remove(m);
		}
	}

	void remove(ItemHolder m, ubyte tab)
	{
		auto sc = scOf(tab);
		auto e = m.parent;

		if(e is sc.rows.back)
		{
			if(e.childs.length == 1)
			{
				sc.remove(e);
			}
			else
			{
				auto s = e.childs[].countUntil!(a => a is m);

				e.childs.remove(m);
				e.childs[s..$].each!(a => a.pos.x -= 36);
			}
		}
		else
		{
			RCArray!ItemHolder arr;

			auto idx = sc.rows[].countUntil!(a => a is e) + 1;
			assert(idx > 0);

			while(idx != sc.rows.length)
			{
				auto r = sc.rows[idx];

				foreach(w; r.childs)
				{
					arr ~= cast(ItemHolder)w;
				}

				sc.remove(r);
			}

			remove(m, tab);
			arr.each!(a => add(a, tab));
		}
	}

	void add(ItemHolder m, ubyte tab)
	{
		GUIElement c;

		{
			auto sc = scOf(tab);

			{
				auto rs = sc.rows[];

				if(!rs.length || (c = rs.back).childs.length == 7)
				{
					c = new GUIElement(null);
					c.size = Vector2s(36 * 7, 36);

					sc.add(c, true);
				}
			}
		}

		m.parent = c;
		m.pos = Vector2s(c.childs.length * 36, 0);

		c.childs ~= m;
	}

	auto scOf(ubyte idx)
	{
		return cast(Scrolled)tabWin
									.tabs[idx]
									.childs
									.front;
	}

	inout tabWin()
	{
		return cast(TabWindow)childs.back;
	}

	ItemHolder[Item] _aa;
}

final class WinStorage : WinBasic
{
	this()
	{
		name = `storage`;

		auto sz = Vector2s(7, 4);

		{
			tab = new InventoryTab(this, sz);
			tab.pos = Vector2s(2) + Vector2s(0, WIN_TOP_SZ.y);

			sz = tab.pos + tab.size + Vector2s(0, WIN_BOTTOM_SZ.y) + Vector2s(2) + Vector2s(0, sz.y <= 2 ? -10 : 0);

			super(sz, MSG_STORAGE);
		}

		{
			auto b = new Button(this, MSG_CLOSE);

			b.pos = size - Vector2s(b.size.x + 4, (WIN_BOTTOM_SZ.y + b.size.y) / 2);
			b.onClick = () => ROnet.storeClose;
		}

		items.onAdded.permanent(&onAdd);
	}

	Items items;
	InventoryTab tab;
private:
	void onAdd(Item m)
	{
		m.source = ITEM_STORAGE;
		tab.register(m);
	}
}

final class WinInventory : WinBasic
{
	this()
	{
		name = `inventory`;

		auto sz = Vector2s(7, 2);

		{
			tab = new InventoryTab(this, sz);
			tab.pos = Vector2s(2) + Vector2s(0, WIN_TOP_SZ.y);

			sz = tab.pos + tab.size + Vector2s(0, WIN_BOTTOM_SZ.y) + Vector2s(2) + Vector2s(0, sz.y <= 2 ? -10 : 0);

			super(sz, MSG_INVENTORY);
		}

		if(pos.x < 0)
		{
			pos = Vector2s(0, RO.gui.base.size.y);
		}

		RO.status.items.onAdded.permanent(&tab.register);
	}

	InventoryTab tab;

	mixin StatusValue!(uint, `zeny`, onUpdate);
	mixin StatusValue!(uint, `weight`, onUpdate);
	mixin StatusValue!(uint, `maxWeight`, onUpdate);
private:
	void onUpdate()
	{
		if(childs.length > 2)
		{
			childs.popBack;
		}

		auto e = new GUIStaticText(this, format(`%s Ƶ, %s: %u / %u`, price(zeny), MSG_WEIGHT, weight, maxWeight));
		e.pos = Vector2s(tab.pos.x + INV_TAB_ITEM_SZ.x, size.y - (WIN_BOTTOM_SZ.y + e.size.y) / 2);
	}
}

final class ItemHolder : GUIElement
{
	this(GUIElement p, Item m)
	{
		super(p, Vector2s(36));

		{
			auto e = new ItemIcon(this, m);
			e.pos = Vector2s(6);
		}

		_rc = m.onCountChanged.add(&recount);
	}

private:
	void recount(Item m)
	{
		while(childs.length > 1)
		{
			childs.popBack;
		}

		if(m.amount > 1)
		{
			auto im = new GUIStaticText(this, m.amount.to!string, 0, PE.fonts.small);
			im.pos = Vector2s(30) - im.size / 2;

			im.pos.x = cast(short)min(im.pos.x, size.x - im.size.x); // TODO: REMAKE ?
			im.pos.y = cast(short)min(im.pos.y, size.y - im.size.y);
		}

		PE.gui.updateMouse;
	}

	RC!ConnectionPoint _rc;
}
