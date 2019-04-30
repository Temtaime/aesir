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

		{
			auto msgs =
			[
				MSG_ITM,
				MSG_EQP,
				MSG_ETC
			];

			new TextTabs(this, msgs);

			foreach(u; tt.tabs)
			{
				auto sc = new Scrolled(u, sz, 36);
				sc.size.x += 36 * sz.x;
			}

			tt.adjust;
		}

		foreach(i; 0..sz.x)
		foreach(j; 0..sz.y)
		{
			auto im = new GUIImage(this, INV_ITEM);

			im.pos = tt.tabs[0].pos;
			im.pos += Vector2s(i, j) * 36 + (Vector2s(36) - im.size) / 2;
		}

		tt.bringToTop;
		toChildSize;
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
	auto scOf(ubyte tab)
	{
		return cast(Scrolled)tt.tabs[tab].childs[0];
	}

	void add(Item m)
	{
		scOf(m.tab).add(_aa[m] = new ItemHolder(m));
	}

	void remove(Item m)
	{
		if(auto p = m in _aa)
		{
			scOf(m.tab).remove(*p);
			_aa.remove(m);
		}
	}

	ItemHolder[Item] _aa;
	mixin MakeChildRef!(TextTabs, `tt`, 0);
}

final class WinStorage : WinBasic2
{
	this()
	{
		super(MSG_STORAGE, `storage`);

		auto tab = new InventoryTab(main, Vector2s(7, 4));
		adjust;

		{
			auto b = new Button(bottom, MSG_CLOSE);

			b.move(POS_MIN, 5, POS_CENTER);
			b.onClick = () => ROnet.storeClose;
		}

		items.onAdded.permanent(&tab.register);
	}

	Items items;
}

final class WinInventory : WinBasic2
{
	this()
	{
		super(MSG_INVENTORY, `inventory`);

		new InventoryTab(main, Vector2s(7, 2));
		adjust;

		RO.status.items.onAdded.permanent(&tab.register);
	}

	mixin StatusValue!(uint, `zeny`, onUpdate);
	mixin StatusValue!(uint, `weight`, onUpdate);
	mixin StatusValue!(uint, `maxWeight`, onUpdate);
private:
	void onUpdate()
	{
		bottom.childs.clear;

		auto e = new GUIStaticText(bottom, format(`%s Ƶ, %s: %u / %u`, price(zeny), MSG_WEIGHT, weight, maxWeight));
		e.move(POS_MIN, 5, POS_CENTER);
	}

	mixin MakeChildRef!(InventoryTab, `tab`, 0);
}

final class ItemHolder : GUIElement
{
	this(Item m)
	{
		super(null, 36.Vector2s);

		{
			auto e = new ItemIcon(this, m);
			e.center;
		}

		_rc = m.onCountChanged.add(&recount);
	}

private:
	void recount(Item m)
	{
		if(childs.length > 1)
		{
			childs.popBack;
		}

		if(m.amount > 1)
		{
			FontInfo fi =
			{
				font: PE.fonts.small
			};

			auto im = new GUIStaticText(this, m.amount.to!string, fi);
			im.pos = Vector2s(30) - im.size / 2;

			im.pos.x = cast(short)min(im.pos.x, size.x - im.size.x); // TODO: REMAKE ?
			im.pos.y = cast(short)min(im.pos.y, size.y - im.size.y);
		}

		PE.gui.updateMouse;
	}

	RC!ConnectionPoint _rc;
}
