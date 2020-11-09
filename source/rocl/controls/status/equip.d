module rocl.controls.status.equip;

import std.meta, perfontain, ro.conv.gui, rocl, rocl.status, rocl.controls;

final:

class EquipSlot : GUIElement
{
	this(GUIElement win, string name, ushort w, Color c = Color(128, 128, 128, 200))
	{
		// super(win);

		// {
		// 	auto arr = PE.fonts.base.toLines(name, cast(ushort)(w - 36), 2);

		// 	foreach(i, s; arr)
		// 	{
		// 		auto e = new GUIStaticText(this, s);

		// 		e.pos = Vector2s(36, 35 - (i || arr.length == 1 ? 1 : 2) * e.size.y);
		// 		e.color = c;
		// 	}
		// }

		// size = Vector2s(w, 36);
	}

	this(GUIElement win, Item m, ushort w)
	{
		this(win, m.data.name, w, colorBlack);

		// auto e = new ItemIcon(this, m);
		// e.pos = Vector2s(6);
	}

	/*override void draw(Vector2s p) const
	{
		auto n = p + pos;

		drawQuad(n + Vector2s(36, 35), Vector2s(size.x - 36, 1), Color(128, 128, 128, 200));
		drawImage(INV_ITEM, n + (Vector2s(36) - INV_ITEM_SZ) / 2, colorWhite, INV_ITEM_SZ);

		super.draw(p);
	}*/
}

class EquipView : GUIElement
{
	this(GUIElement win, ushort w)
	{
		// super(win);

		// RO.status.items.onAdded.permanent(&register);

		// foreach(i, s; aliasSeqOf!Names)
		// {
		// 	auto e = new EquipSlot(this, mixin(s), w / 2);
		// 	e.pos = Vector2s(i > 4 ? w / 2 : 0, i % 5 * 36);
		// }

		// size = Vector2s(w, 36 * 5);
	}

private:
	void register(Item m)
	{
		if (m.equip)
		{
			if (m.equip2)
			{
				equip(m);
			}

			m.onEquip.permanent(a => equip(a));
			m.onUnequip.permanent(a => equip(a, false));
			m.onRemove.permanent(&remove);
		}
	}

	void remove(Item m)
	{
		if (m.equip2)
		{
			equip(m, false);
		}
	}

	void equip(Item m, bool equip = true)
	{
		// enum Poses =
		// [
		// 	EQP_HEAD_TOP,
		// 	EQP_HEAD_LOW,
		// 	EQP_HAND_R,
		// 	EQP_GARMENT,
		// 	EQP_ACC_R,
		// 	EQP_HEAD_MID,
		// 	EQP_ARMOR,
		// 	EQP_HAND_L,
		// 	EQP_SHOES,
		// 	EQP_ACC_L
		// ];

		// foreach(i, u; aliasSeqOf!Poses)
		// {
		// 	if(m.equip2 & u)
		// 	{
		// 		EquipSlot e;

		// 		if(equip)
		// 		{
		// 			e = new EquipSlot(null, m, ushort(size.x) / 2);
		// 		}
		// 		else
		// 		{
		// 			e = new EquipSlot(null, mixin(Names[i]), ushort(size.x) / 2);
		// 		}

		// 		e.pos = childs[i].pos;
		// 		e.parent = this;

		// 		childs[i] = e;
		// 	}
		// }
	}

	enum Names = [
			`MSG_HEAD`, `MSG_HEAD`, `MSG_HAND_R`, `MSG_ROBE`, `MSG_ACC`,
			`MSG_HEAD`, `MSG_ARMOR`, `MSG_HAND_L`, `MSG_SHOES`, `MSG_ACC`
		];
}
