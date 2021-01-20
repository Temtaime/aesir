module rocl.controls.status;
import std, perfontain, perfontain.opengl, ro.grf, ro.conv.gui, rocl,
	rocl.game, rocl.status, rocl.controls, rocl.controls.status.equip,
	rocl.controls.status.stats, rocl.controls.status.bonuses, rocl.network.packets, rocl.gui.misc;

final:

class WinStatus : GUIWindow
{
	this()
	{
		super(MSG_CHARACTER, Vector2s(400));

		auto m = new MenuLayout(MSG_EQUIPMENT);
		addLayout(m);
		equip = new EquipTab(m);

		m = new MenuLayout(MSG_STATS);
		addLayout(m);
		stats = new StatsTab(m);
	}

	EquipTab equip;
	StatsTab stats;
}

class EquipTab
{
	this(MenuLayout m)
	{
		{
			auto r = cast(uint)ctx.style.combo.content_padding.y.lrint;
			_layout = new DynamicRowLayout(2, 24 + r * 2);

			m.layouts ~= _layout;
		}

		_layout.styles ~= new Style(&ctx.style.combo.button_padding.y, 8); // make scroll arrow a bit smaller

		_slots = [
			Slot(EQP_HEAD_TOP, MSG_HEAD), Slot(EQP_HEAD_MID, MSG_HEAD),
			Slot(EQP_HEAD_LOW, MSG_HEAD), Slot(EQP_ARMOR, MSG_ARMOR),
			Slot(EQP_HAND_R, MSG_HAND_R), Slot(EQP_HAND_L, MSG_HAND_L),
			Slot(EQP_GARMENT, MSG_ROBE), Slot(EQP_SHOES, MSG_SHOES),
			Slot(EQP_ACC_R, MSG_ACC), Slot(EQP_ACC_L, MSG_ACC)
		];

		RO.status.items.onAdded.permanent(&register);

		foreach (ref s; _slots)
		{
			auto wrap = () {
				auto slot = &s;
				auto combo = new ImageCombo(_layout);

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

private:
	mixin Nuklear;

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
			auto combo = cast(ImageCombo)_layout.childs[idx];

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

	Layout _layout;
	Slot[10] _slots; // immutable, DMD BUG
}

class StatsTab
{
	this(MenuLayout m)
	{
		_menu = m;
		create;
	}

	void update(ref Stat st)
	{
		_menu.layouts.clear;
		create;
	}

private:
	mixin Nuklear;

	void create()
	{
		auto w = 30;

		auto layout = new class RowTemplateLayout
		{
			this()
			{
				super(0);
			}

			override void make()
			{
				dynamic();
				static_(w);
			}
		};

		_menu.layouts ~= layout;

		foreach (i, st; Stats)
		{
			auto v = &RO.status.stats[i];

			if (v.needs)
				new PropertyInt(layout, st ~ ':', v.base, 1, 100, 1, 1);
			else
				new GUIStaticText(layout, st ~ `: ` ~ v.base.to!string);

			new GUIStaticText(layout, `+ ` ~ v.bonus.to!string);
		}
	}

	MenuLayout _menu;
	static immutable Stats = [`STR`, `AGI`, `VIT`, `INT`, `DEX`, `LUK`];
}
