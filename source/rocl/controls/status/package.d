module rocl.controls.status;
import std, perfontain, perfontain.opengl, ro.grf, ro.conv.gui, rocl,
	rocl.game, rocl.status, rocl.controls, rocl.controls.status.equip,
	rocl.controls.status.stats, rocl.controls.status.bonuses, rocl.network.packets, rocl.gui.misc;

final class WinStatus : GUIWindow
{
	this()
	{
		super(MSG_CHARACTER, Vector2s(400));

		{
			_table = [
				Slot(EQP_HEAD_TOP, MSG_HEAD), Slot(EQP_HEAD_MID, MSG_HEAD),
				Slot(EQP_HEAD_LOW, MSG_HEAD), Slot(EQP_ARMOR, MSG_ARMOR),
				Slot(EQP_HAND_R, MSG_HAND_R), Slot(EQP_HAND_L, MSG_HAND_L),
				Slot(EQP_GARMENT, MSG_ROBE), Slot(EQP_SHOES, MSG_SHOES),
				Slot(EQP_ACC_R, MSG_ACC), Slot(EQP_ACC_L, MSG_ACC)
			];

			auto r = cast(uint)ctx.style.combo.content_padding.y.lrint;

			addLayout(new DynamicRowLayout(2, 24 + r * 2));
			curLayout.menu = MSG_EQUIPMENT;
			curLayout.styles ~= new Style(&ctx.style.combo.button_padding.y, 8); // make scroll arrow a bit smaller

			RO.status.items.onAdded.permanent(&register);

			foreach (i, ref slot; _table)
			{
				auto wrap = () {
					uint k = cast(uint)i;
					auto combo = new ImageCombo(curLayout);

					combo.onChange = (idx) {
						if (auto n = idx ? idx : combo.selected)
						{
							itemsForSlot(&_table[k], null)[n - 1].action; //const m = _table[k].items[n - 1];
							//RO.status.items.getIdx(m).action;
						}

						return false;
					};

					combo.add(slot.name, null);
				};

				wrap();
			}
		}

		addLayout(new DynamicRowLayout(2, 36));
		curLayout.menu = MSG_STATS;
	}

private:
	void register(Item m)
	{
		if (m.equip)
		{
			{
				auto slots = slotsForItem(m);
				slots.each!(a => a.items ~= m.idx);
				slots.each!(a => fill(a, true));
			}

			m.onEquip.permanent(a => onEquip(a, true));
			m.onUnequip.permanent(a => onEquip(a, false));
			m.onRemove.permanent(&onRemove);
		}
	}

	void onRemove(Item m)
	{
		auto slots = slotsForItem(m);
		slots.each!(a => a.items = a.items.remove!(a => a == m.idx));
		slots.each!(a => fill(a, false));
	}

	void onEquip(Item m, bool equip)
	{
		auto slots = slotsForItem(m);
		slots.each!(a => fill(a, equip));
	}

	auto slotsForItem(Item m)
	{
		return _table[].map!((ref a) => &a)
			.filter!(a => a.mask & m.equip)
			.array;
	}

	// void updateSlots(Item m, void delegate(Slot*) dg)
	// {
	// 	_table[].map!((ref a) => &a)
	// 		.filter!(a => a.mask & m.equip)
	// 		.each!dg;
	// }

	void fill(Slot* slot, Item unequip)
	{
		// auto combo = slot.combo;

		// combo.clear;
		// combo.add(slot.name, null);

		// foreach (i, m; slot.items
		// 		.map!(a => RO.status.items.getIdx(a))
		// 		.filter!(a => !a.equip2 || a.equip2 & slot.mask)
		// 		.enumerate)
		// {
		// 	auto data = m.data;
		// 	combo.add(data.name, makeIconTex(data.res));

		// 	if (canEquip && m.equip2)
		// 		combo.selected = cast(uint) i + 1;
		// }

		auto combo = _layouts[0].childs[slot - _table.ptr];
		auto items = itemsForSlot(slot, unequip);

		combo.clear;
		combo.add(slot.name, null);

		foreach (i, m; items)
		{
			auto data = m.data;
			combo.add(data.name, makeIconTex(data.res));

			if (canEquip && m.equip2 & slot.mask)
				combo.selected = cast(uint)i + 1;
		}
	}

	auto itemsForSlot(Slot* s, Item unequip)
	{
		return RO.status.items.get(a => !!((a is unequip || !a.equip2 ? a.equip : a.equip2) & s
				.mask));
	}

	struct Slot
	{
		uint mask;
		string name;
	}

	static immutable Slot[10] _table;
}
