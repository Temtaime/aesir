module rocl.controls.bars;

import
		std.algorithm,

		perfontain;


final:

class CastBar : GUIQuad
{
	this(uint dur)
	{
		_dur = dur;
		_tick = PE.tick;

		super(PE.gui.root, Color(0, 0, 0, 255));

		size = Vector2s(60, 6);
	}

	override void draw(Vector2s p) const
	{
		super.draw(p);

		auto w = size.x - 2;
		auto k = min(w * (PE.tick - _tick) / _dur, w);

		if(k)
		{
			drawQuad(p + pos + Vector2s(1), Vector2s(k, size.y - 2), Color(85, 205, 120, 255));
		}
	}

private:
	uint
			_dur,
			_tick;
}

class HpBar : GUIElement
{
	this()
	{
		super(PE.gui.root, Vector2s(60, 9));
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p += pos, Vector2s(size.x, maxSp ? size.y : size.y - 4), Color(0, 0, 0, 255));

		auto w = size.x - 2;

		if(maxHp)
		{
			if(auto n = w * hp / maxHp)
			{
				drawQuad(p + Vector2s(1), Vector2s(min(w, n), 3), hp > maxHp / 5 ? Color(85, 205, 120, 255) : Color(255, 30, 145, 255));
			}
		}

		if(maxSp)
		{
			if(auto n = w * sp / maxSp)
			{
				drawQuad(p + Vector2s(1, 5), Vector2s(min(w, n), 3), Color(30, 145, 255, 255));
			}
		}
	}

	uint
			hp,
			sp,
			maxHp,
			maxSp;
private:
	uint
			_dur,
			_tick;
}
