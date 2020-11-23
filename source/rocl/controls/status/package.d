module rocl.controls.status;
import std, perfontain, perfontain.opengl, ro.grf, ro.conv.gui, rocl,
	rocl.game, rocl.status, rocl.controls, rocl.controls.status.equip,
	rocl.controls.status.stats, rocl.controls.status.bonuses, rocl.network.packets, rocl.gui.misc;

final class WinStatus : GUIWindow
{
	this()
	{
		super(MSG_CHARACTER, Vector2s(400));

		_slots = [
			Slot(EQP_HEAD_TOP, MSG_HEAD), Slot(EQP_HEAD_MID, MSG_HEAD),
			Slot(EQP_HEAD_LOW, MSG_HEAD), Slot(EQP_ARMOR, MSG_ARMOR),
			Slot(EQP_HAND_R, MSG_HAND_R), Slot(EQP_HAND_L, MSG_HAND_L),
			Slot(EQP_GARMENT, MSG_ROBE), Slot(EQP_SHOES, MSG_SHOES),
			Slot(EQP_ACC_R, MSG_ACC), Slot(EQP_ACC_L, MSG_ACC)
		];

		{
			auto r = cast(uint)ctx.style.combo.content_padding.y.lrint;

			addLayout(new DynamicRowLayout(2, 24 + r * 2));
			curLayout.menu = MSG_EQUIPMENT;
			curLayout.styles ~= new Style(&ctx.style.combo.button_padding.y, 8); // make scroll arrow a bit smaller

			RO.status.items.onAdded.permanent(&register);

			foreach (ref s; _slots)
			{
				auto wrap = () {
					auto slot = &s;
					auto combo = new ImageCombo(curLayout);

					combo.onChange = (idx) {
						if (auto n = idx ? idx : combo.selected)
						{
							itemsForSlot(slot.mask)[n - 1].action;
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
			process(m);

			m.onEquip.permanent(&process);
			m.onUnequip.permanent((a, _) => process(a));
			m.onRemove.permanent(&process);
		}
	}

	void process(Item m)
	{
		foreach (idx, slot; _slots[].enumerate.filter!(a => a.value.mask & m.equip))
		{
			auto items = itemsForSlot(slot.mask);
			auto combo = cast(ImageCombo)_layouts[0].childs[idx];

			combo.clear;
			combo.add(slot.name, null);

			foreach (i, e; items)
			{
				auto data = e.data;
				combo.add(data.name, makeIconTex(data.res));

				if (e.equip2 & slot.mask)
					combo.selected = cast(uint)i + 1;
			}
		}
	}

	auto itemsForSlot(uint mask)
	{
		return RO.status.items.get(a => !!((a.equip2 ? a.equip2 : a.equip) & mask));
	}

	struct Slot
	{
		uint mask;
		string name;
	}

	Slot[10] _slots; // immutable, DMD BUG
}
