
module rocl.controls.status;

import
		std.utf,
		std.meta,
		std.conv,
		std.range,
		std.string,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv.gui,

		rocl,
		rocl.game,
		rocl.status,
		rocl.controls,
		rocl.controls.status.equip,
		rocl.controls.status.stats,
		rocl.controls.status.bonuses,
		rocl.network.packets;


final class WinStatus : WinBasic
{
	this()
	{
		ushort
				y,
				w = 360;

		{
			equip = new EquipView(this, w);
			equip.pos = Vector2s(10, 20);

			y += equip.pos.y + equip.size.y + 10;
		}

		{
			stats = new StatsView(this, 130);
			stats.pos = Vector2s(10, y);
		}

		{
			auto x = cast(ushort)(20 + stats.size.x);

			bonuses = new BonusesView(this, cast(ushort)(w - x + 10));
			bonuses.pos = Vector2s(x, y);
		}

		y += stats.size.y;

		{
			name = `status`;

			super(Vector2s(w + 20, y + 36), MSG_EQUIPMENT);

			if(pos.x < 0)
			{
				pos.x = cast(ushort)((PE.window.size.x - size.x) / 2);
			}
		}
	}

	StatsView stats;
	EquipView equip;
	BonusesView bonuses;
}
