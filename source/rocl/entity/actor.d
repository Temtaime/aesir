module rocl.entity.actor;
import std.algorithm, perfontain, ro.grf, ro.path, rocl.game, rocl.status, rocl.network, rocl.entity.misc,
	rocl.loaders.asp, rocl.entity.visual;

abstract class Actor : RCounted
{
	static Actor create(in ActorInfo p)
	{
		final switch (p.type)
		{
		case BL_PC:
			return new Player(p);
		case BL_MOB:
			return new Mob(p);
		case BL_NPC_EVT:
			return new Npc(p);
		}
	}

	this(in ActorInfo p)
	{
		bl = p.bl;
		name = p.name;

		ent = new Entity(p.class_, p.type, _gender = !!p.gender);
		ent.speed = p.speed;
	}

	void changeLook(ubyte, ushort)
	{
	}

	string cleanName() const
	{
		return name;
	}

	bool act()
	{
		return false;
	}

	void doAttack(in Pk08c8 p)
	{
		if (!ROent.doActor(p.dstId, &onDir))
		{
			ent.dir = 0;
			logger.msg!`no dir %s %s`(p.dstId, ROent.self.bl);
		}

		ent.act(Action.attack, Action.readyFight, cast(ushort)p.srcSpeed);
	}

	void move(Vector2s p, Vector2s to) // DMD BUG ?
	{
		ent.move(p, to);
	}

	auto opDispatch(string s, A...)(auto ref A args)
	{
		return mixin(`ent.` ~ s ~ `(args)`);
	}

	const uint bl;

	string name;
	Vector2 pos;

	RC!Entity ent;
package:
	void onDir(Actor a)
	{
		with (ent)
		{
			dir = direction(a.pos2 - pos2, true);
		}
	}

	bool _gender;
}

final class Mob : Actor
{
	this(in ActorInfo p)
	{
		super(p);
	}

	override bool act()
	{
		ROnet.attackMob(bl);
		return true;
	}
}

final class Npc : Actor
{
	this(in ActorInfo p)
	{
		super(p);
	}

	override bool act()
	{
		ROnet.talkNpc(bl);
		return true;
	}

	override string cleanName() const
	{
		auto k = name.toByte.countUntil('#');
		auto r = k < 0 ? name : name[0 .. k];

		return r.length ? r : `???`;
	}
}

final class Player : Actor
{
	this(in ActorInfo p)
	{
		super(p);

		if (auto id = p.hairStyle)
		{
			ent.add(SPR_HEAD, AspLoadInfo(id, 0, ASP_HEAD, !!p.gender, cast(ubyte)p.hairColor));
		}

		if (auto id = p.headTop)
		{
			changeLook(LOOK_HEAD_TOP, id);
		}

		if (auto id = p.headMiddle)
		{
			changeLook(LOOK_HEAD_MID, id);
		}

		if (auto id = p.headBottom)
		{
			changeLook(LOOK_HEAD_BOTTOM, id);
		}

		ent.head = 0;
	}

	override void changeLook(ubyte type, ushort id)
	{
		switch (type)
		{
		case LOOK_HEAD_TOP:
			ent.add(SPR_HEAD_TOP, AspLoadInfo(id, 0, ASP_HEAD_TOP, _gender));
			break;

		case LOOK_HEAD_MID:
			ent.add(SPR_HEAD_MIDDLE, AspLoadInfo(id, 0, ASP_HEAD_MIDDLE, _gender));
			break;

		case LOOK_HEAD_BOTTOM:
			ent.add(SPR_HEAD_BOTTOM, AspLoadInfo(id, 0, ASP_HEAD_BOTTOM, _gender));
			break;

		default:
		}
	}
}
