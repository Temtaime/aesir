module rocl.controls.numbers;

import
		std.conv,
		std.math,
		std.array,
		std.stdio,
		std.algorithm,

		perfontain,
		perfontain.math,

		rocl.game,
		rocl.paths,
		rocl.entity.actor;


final class ValueManager : RCounted
{
	this()
	{
		/*auto f = asRC(new Font(`data/font/mechanical-out.ttf`, 72));

		foreach(i; 0..10)
		{
			auto im = f.render(i.to!string);
			auto sz = Vector2s(im.w, im.h);

			_ns ~= PEobjs.makeOb(im.makeTexInfo);

			if(i)
			{
				assert(sz == _sz);
			}
			else
			{
				_sz = sz;
			}
		}*/
	}

	auto show(Vector3 pos, uint num)
	{
		return add(pos, num, DamageType.Skill, 5_000);
	}

	void show(Actor a, uint num)
	{
		add(a.ent.pos, num, a.castSwitch!(
											(Player a) => DamageType.Player,
											(Actor a) => DamageType.Mob
																		));
	}

private:
	auto add(Vector3 pos, uint num, DamageType tp, uint t = 1_000)
	{
		// auto e = new Damage(pos, num, tp, t);

		// // auto f =
		// // {
		// // 	e.deattach;
		// // };

		// return PE.timers.add(f, t, TM_ONCE);
	}

	Vector2s _sz;
	RCArray!MeshHolder _ns;
}

enum DamageType
{
	Mob,
	Player,
	Skill,
}

class Damage //: GUIElement
{
	this(Vector3 pos, uint n, DamageType tp, uint t)
	{
		//super(PE.gui.root);

		_pos = pos;
		_delay = t;
		_start = PE.tick;

		_tp = tp;
		_ids = n.to!string.map!(a => cast(ubyte)(a - '0')).array;

		//flags.background = true;
	}

	/*override void draw(Vector2s p) const
	{
		auto n = project(_pos * PE.scene.viewProject, PE.window.size).xy.Vector2s;

		//n += Vector2s(-_ids.length * vm._ms.x, vm._ms.y / 2);

		float r;

		if(_tp == DamageType.Skill)
		{
			n.y -= cast(short)(perc * 40);
			r = 1;
		}
		else
		{
			auto t = sin(perc * PI / 2) * 100;
			auto z = sin(perc * PI * 3 / 4) * 100;

			n += Vector2s(t, z * -1.5);
			r = max(1 - perc, 0.4) * 0.5;
		}

		auto c = color;

		foreach(i, k; _ids)
		{
			auto sz = Vector2s(vm._sz.Vector2 * r);

			drawImage(vm._ns[k], 0, n + Vector2s(i * vm._sz.x * r, 0), c, sz);
		}
	}*/

private:
	const color()
	{
		Color c;

		final switch(_tp)
		{
		case DamageType.Skill:		c = Color(235, 255, 15);	break;
		case DamageType.Player:		c = Color(255, 0, 0);		break;
		case DamageType.Mob:		c = Color(255, 255, 255);	break;
		}

		c.a = cast(ubyte)(min(1, 1 - (perc - 4f / 5) * 5) * 255);
		return c;
	}

	static vm()
	{
		return cast(ValueManager)RO.gui.values;
	}

	const perc()
	{
		return float(PE.tick - _start) / _delay;
	}

	uint _start, _delay;
	Vector3 _pos;

	ubyte[] _ids;

	DamageType _tp;
}
