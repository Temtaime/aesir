module rocl.controls.inventory;

import std.meta, std.conv, std.range, std.string, std.algorithm, perfontain,

	ro.db, ro.conv, ro.conv.gui, ro.conv.item, rocl, rocl.gui.misc, rocl.game,
	rocl.paths, rocl.status, rocl.status.helpers, rocl.network, rocl.controls;

// final class InventoryTab : GUIElement
// {
// 	this(GUIElement p, Vector2s sz)
// 	{
// 		super(p);

// 		{
// 			auto msgs = [MSG_ITM, MSG_EQP, MSG_ETC];

// 			auto e = new TextTabs(this, msgs);

// 			foreach (u; e.tabs)
// 			{
// 				auto sc = new Scrolled(u, sz, 36);
// 				sc.size.x += 36 * sz.x;
// 			}

// 			e.adjust;

// 			foreach (i; 0 .. sz.x)
// 				foreach (j; 0 .. sz.y)
// 				{
// 					auto im = new GUIImage(this, INV_ITEM);

// 					im.pos = e.tabs[0].pos;
// 					im.pos += Vector2s(i, j) * 36 + (Vector2s(36) - im.size) / 2;
// 				}

// 			e.bringToTop;
// 		}

// 		toChildSize;
// 	}

// 	void register(Item m)
// 	{
// 		if (!m.equip2)
// 		{
// 			add(m);
// 		}

// 		if (m.equip)
// 		{
// 			m.onEquip.permanent(&remove);
// 			m.onUnequip.permanent(&add);
// 		}

// 		m.onRemove.permanent(&remove);
// 	}

// private:
// 	auto scOf(ubyte tab)
// 	{
// 		auto e = cast(TextTabs) childs.back;
// 		return cast(Scrolled) e.tabs[tab].childs[0];
// 	}

// 	void add(Item m)
// 	{
// 		scOf(m.tab).add(_aa[m] = new ItemHolder(m));
// 	}

// 	void remove(Item m)
// 	{
// 		if (auto p = m in _aa)
// 		{
// 			scOf(m.tab).remove(*p);
// 			_aa.remove(m);
// 		}
// 	}

// 	ItemHolder[Item] _aa;
// }

// final class WinStorage : WinBasic2
// {
// 	this()
// 	{
// 		super(MSG_STORAGE, `storage`);

// 		auto e = new InventoryTab(main, Vector2s(7, 4));
// 		adjust;

// 		{
// 			auto b = new Button(bottom, MSG_CLOSE);

// 			b.move(POS_MIN, 5, POS_CENTER);
// 			b.onClick = () => ROnet.storeClose;
// 		}

// 		items.onAdded.permanent(&e.register);
// 	}

// 	Items items;
// }

struct WinInventory
{
	void draw()
	{
		auto tabs = [MSG_ITM, MSG_EQP, MSG_ETC];

		if (auto win = Window(MSG_INVENTORY, nk_vec2(200, 200)))
		{
			{
				auto s = format(`%s Z, %s: %u / %u`, price(zeny), MSG_WEIGHT, weight, maxWeight); // TODO: Ƶ

				nk.tabSelector(tabs, _tab, (ref a) => a.variable(widthFor(s)),
						() => nk.label(s, NK_TEXT_RIGHT));
			}

			drawTab;
		}
	}

	mixin StatusValue!(uint, `zeny`, update);
	mixin StatusValue!(uint, `weight`, update);
	mixin StatusValue!(uint, `maxWeight`, update);
private:
	mixin NuklearBase;

	void drawTab()
	{
		auto s1 = Style(&ctx.style.window.spacing, nk_vec2(0, 0));

		enum SZ = 36;
		nk.layout_row_static(SZ, SZ, nk.maxColumns(SZ));

		foreach (e; RO.status.items.arr[].filter!(a => a.tab == _tab))
		{
			scope r = new ItemIcon(e);
			r.draw;
		}
	}

	ubyte _tab;

	// void onChange(ushort idx)
	// {
	// 	curLayout.childs.clear;

	// 	foreach (e; RO.status.items.arr[].filter!(a => a.tab == idx))
	// 	{
	// 		auto data = e.data;

	// 		new ItemIcon(curLayout, makeIconTex(data.res), data.name, e.amount);

	// 		//new GUIStaticText(curLayout, e.amount.to!string);
	// 	}
	// }

	void update()
	{
		// bottom.childs.clear;

		// auto e = new GUIStaticText(bottom, );
		// e.move(POS_MIN, 5, POS_CENTER);
	}
}
