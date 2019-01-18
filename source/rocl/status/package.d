module rocl.status;

import
		std.array,
		std.typecons,
		std.algorithm,

		perfontain,

		rocl.controls,
		rocl.status.helpers;

public import
				rocl.game,
				rocl.status.item,
				rocl.status.enums;


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

	// misc
	string map;

	// character
	Stat[RO_STAT_MAX] stats;
	Bonus[RO_BONUS_MAX] bonuses;

	// skills
	Skill[] skills;

	Items items;

	// rest
	Param!uint	hp,
				sp,
				maxHp,
				maxSp,

				bexp,
				jexp,
				bnextExp,
				jnextExp;

	Param!ushort	blvl,
					jlvl;
}

struct Items
{
	void clear()
	{
		arr = null;
	}

	void add(Item m)
	{
		assert(!getIdx(m.idx));

		arr ~= m;
		onAdded(m);
	}

	void remove(Item m)
	{
		arr.remove(m);
	}

	auto getIdx(ushort idx)
	{
		auto r = get(a => a.idx == idx);
		assert(r.length < 2);
		return r.empty ? null : r.front;
	}

	auto get(scope bool delegate(Item) dg)
	{
		return arr[]
						.filter!dg
						.array
						.sort!((a, b) => a.idx < b.idx)
						.release;
	}

	RCArray!Item arr;
	Signal!(void, Item) onAdded;
}

struct Param(T)
{
	Signal!(void, T) onChange;

	mixin StatusValue!(T, `value`, onUpdate);
private:
	void onUpdate()
	{
		onChange(value);
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
		RO.gui.status.stats.update(this);
	}
}

struct Bonus
{
	mixin StatusIndex!(`bonuses`);

	mixin StatusValue!(short, `base`, onUpdate);
	mixin StatusValue!(short, `base2`, onUpdate);
private:
	void onUpdate()
	{
		RO.gui.status.bonuses.update(this);
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
		if(_bg)
		{
			_bg.deattach;
		}
	}

	void use()
	{
		if(_s.type == INF_SELF_SKILL)
		{
			use(ROent.self.bl);
		}
		else
		{
			RO.action.use(this);
			_bg = new TargetSelector;
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

	GUIElement _bg;
}

final class Skill
{
	mixin StatusIndex!(`skills`);

	ushort id;
	string name;

	ubyte
			type,
			range;

	mixin StatusValue!(ushort, `sp`, onUpdate);
	mixin StatusValue!(ubyte, `lvl`, onUpdate);
	mixin StatusValue!(bool, `upgradable`, onUpdate);
private:
	void onUpdate()
	{
		RO.gui.skills.update(this);
	}
}
