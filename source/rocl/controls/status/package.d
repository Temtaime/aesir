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

			auto r = cast(uint) ctx.style.combo.content_padding.y.lrint;

			addLayout(new DynamicRowLayout(2, 24 + r * 2));
			curLayout.menu = MSG_EQUIPMENT;
			curLayout.styles ~= new Style(&ctx.style.combo.button_padding.y, 8); // make scroll arrow a bit smaller

			RO.status.items.onAdded.permanent(&register);

			foreach (i, ref slot; _table)
			{
				auto wrap = () {
					uint k = cast(uint) i;
					auto combo = slot.combo = new ImageCombo(curLayout);

					combo.onChange = (idx) {
						if (auto n = idx ? idx : combo.selected)
							_table[k].items[n - 1].action;
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
			process(m, true);

			m.onEquip.permanent(a => process(a, true));
			m.onUnequip.permanent(a => process(a, false));
			m.onRemove.permanent(a => process(a, false));
		}
	}

	void onRemove(Item m)
	{
		auto slots = slotsForItem(m);
		slots.each!(a => a.items = a.items.remove!(a => a == m.idx));
		fill(slots);
	}

	auto slotsForItem(Item m)
	{
		return _table[].map!((ref a) => &a)
			.filter!(a => a.mask & m.equip)
			.array;
	}

	void process(Item item, bool canEquip)
	{
		auto arr = _table[].map!((ref a) => &a)
			.filter!(a => a.mask & item.equip);

		foreach (slot; arr)
		{
			auto combo = slot.combo;
			slot.items = RO.status.items.get(a => !!((a.equip2 && canEquip
					? a.equip2 : a.equip) & slot.mask));

			combo.clear;
			combo.add(slot.name, null);

			foreach (i, m; slot.items)
			{
				auto data = m.data;
				combo.add(data.name, makeIconTex(data.res));

				if (canEquip && m.equip2 & slot.mask)
					combo.selected = cast(uint) i + 1;
			}
		}
	}

	struct Slot
	{
		uint mask;
		string name;
		Item[] items;
		ImageCombo combo;
	}

	Slot[10] _table;
}
