module rocl.status;
import std.array, std.typecons, std.algorithm, perfontain, rocl.controls, rocl.status.helpers;
public import rocl.game, rocl.status.item, rocl.status.enums;

final class Status
{
	~this()
	{
		items.clear;
	}

	auto skillOf(ushort id)
	{
		auto arr = skills.find!((a, b) => a.id == b)(id);
		return arr.empty ? null : arr.front;
	}

	ref param(ushort idx)
	{
		return *_params.require(idx, new Param!int);
	}

	// misc
	string map;

	// character
	Stat[RO_STAT_MAX] stats;
	//Bonus[RO_BONUS_MAX] bonuses;

	// skills
	Skill[] skills;

	Items items;

	// rest
	Param!uint hp, sp, maxHp, maxSp, bexp, jexp, bnextExp, jnextExp;
	Param!ushort blvl, jlvl;
private:
	Param!int*[ushort] _params;
}

struct Items
{
	void clear()
	{
		_arr = null;
	}

	// void add(ushort idx, ushort cnt, scope Item delegate() dg)
	// {
	// 	if (auto e = getIdx(idx))
	// 	{
	// 		e.reamount(cast(ushort)(e.amount + cnt));
	// 	}
	// 	else
	// 	{
	// 		if (dg)
	// 			add(dg());
	// 		else
	// 			debug throwError!`item at index %u was not found, cannot add %u to the amount`(idx, cnt);
	// 	}
	// }

	void add(T)(in T data)
	{
		if (auto e = getIdx(data.idx))
		{
			debug
			{
				throwError!`item at index %u is already exist`(data.idx);
			}

			_arr.remove(e);
		}

		add(new Item(data));
	}

	void changeAmount(ushort idx, int cnt, bool isTotal = false, scope Item delegate() dg = null)
	{
		if (auto e = getIdx(idx))
		{
			if (isTotal)
			{
				if (cnt)
					e.reamount(cast(ushort)cnt);
				else
					_arr.remove(e);
			}
			else
			{
				int amount = e.amount + cnt;

				debug
				{
					amount >= 0 || throwError!`item at index %u has amount %u, while new amount is %d`(idx, e.amount, amount);
				}

				if (amount > 0)
					e.reamount(cast(ushort)amount);
				else
					_arr.remove(e);
			}
		}
		else
		{
			if (dg)
			{
				add(dg());
			}
			else
				debug throwError!`tried to process a non-existant item at index %u`(idx);
		}
	}

	auto getIdx(ushort idx)
	{
		auto r = get(a => a.idx == idx);
		assert(r.length < 2);
		return r.empty ? null : r.front;
	}

	auto get(scope bool delegate(Item) dg)
	{
		return arr.filter!dg
			.array
			.sort!((a, b) => a.idx < b.idx)
			.release;
	}

	inout arr() => _arr[];

	Signal!(void, Item) onAdded;
private:
	void add(Item m)
	{
		assert(getIdx(m.idx) is null);

		_arr ~= m;
		onAdded(m);
	}

	RCArray!Item _arr;
}

struct Param(T)
{
	Signal!(void, T) onChange;

	mixin StatusValue!(T, `value`, onUpdate);
private:
	void onUpdate()
	{
		onChange(_value);
	}
}

struct Stat
{
	mixin StatusIndex!(`stats`);

	mixin StatusValue!(ubyte, `base`, onUpdate);
	mixin StatusValue!(ubyte, `bonus`, onUpdate);
	mixin StatusValue!(ubyte, `needs`, onUpdate);
private:
	void onUpdate()
	{
		//RO.gui.status.stats.update(this);
	}
}

final class Skiller : RCounted
{
	this(in Skill s, ubyte lvl)
	{
		_s = s;
		_lvl = lvl ? lvl : s.lvl;
	}

	~this()
	{
		// if (_bg)
		// {
		// 	//_bg.deattach;
		// }
	}

	void use()
	{
		if (_s.type == INF_SELF_SKILL)
		{
			use(ROent.self.bl);
		}
		else
		{
			RO.action.use(this);
			//_bg = new TargetSelector;
		}
	}

	void use(Vector2s p)
	{
		ROnet.useSkill(_lvl, _s.id, p);
	}

	void use(uint bl)
	{
		ROnet.useSkill(_lvl, _s.id, bl);
	}

	@property ground() const
	{
		return _s.type == INF_GROUND_SKILL;
	}

private:
	ubyte _lvl;
	const Skill _s;

	//GUIElement _bg;
}

final class Skill
{
	mixin StatusIndex!(`skills`);

	ushort id;
	string name;

	ubyte type, range;

	mixin StatusValue!(ushort, `sp`, onUpdate);
	mixin StatusValue!(ubyte, `lvl`, onUpdate);
	mixin StatusValue!(bool, `upgradable`, onUpdate);
private:
	void onUpdate()
	{
		//RO.gui.skills.update(this);
	}
}
