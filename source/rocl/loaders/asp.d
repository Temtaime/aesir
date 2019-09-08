module rocl.loaders.asp;

import
		std,

		perfontain,
		perfontain.nodes.sprite,

		ro.conv,
		ro.conv.asp,

		rocl.game,
		rocl.paths,

		utils.logger;


enum : ubyte
{
	BL_PC,
	BL_NPC,
	BL_ITEM,
	BL_SKILL,
	BL_CHAT,
	BL_MOB,
	BL_NPC_EVT,
	BL_PET,
	BL_HOM,
	BL_MER,
	BL_ELEM,
}

enum : ubyte
{
	ASP_BODY,
	ASP_HEAD,
	ASP_HEAD_BOTTOM,
	ASP_HEAD_MIDDLE,
	ASP_HEAD_TOP,
	ASP_WEAPON,
	ASP_SHIELD,
}

// any : id, gender
// equipement : id, jobId, gender

struct AspLoadInfo
{
	ushort
			id,
			jobId;

	ubyte type;
	bool gender;
	ubyte palette;

	mixin readableToString;
}

auto loadASP(in AspLoadInfo r)
{
	SpriteObject res;

	logger.info3(`loading sprite: %s`, r);

	string	path,
			kpath;

	ushort id = r.id;

	final switch(r.type)
	{
	case ASP_BODY:
		if(id == 45 || id == 111 || id == 139)
		{
			break;
		}

		if(id < 45 || id >= 4000 && id < 6000)
		{
			auto name = ROdb.jobName(id);

			path = jobPath(id, r.gender);
			kpath = format(`data/sprite/인간족/몸통/%1$s/%2$s_%1$s`, r.gender.koreanSex, name);
		}
		else if(id < 4000)
		{
			auto isNpc = id < 1000;

			path = actorPath(id);
			kpath = `data/sprite/` ~ (isNpc ? `npc` : `몬스터`) ~ `/` ~ ROdb.actorOf(id);
		}
		else
		{
			// 'data/sprite/homun/' + ( MonsterTable[id] || MonsterTable[1002] ).toLowerCase();
		}

		break;

	case ASP_HEAD:
		path = headPath(id, r.gender, r.palette);
		kpath = format(`data/sprite/인간족/머리통/%1$s/%2$u_%1$s`, r.gender.koreanSex, id);

		break;

	case ASP_HEAD_BOTTOM:
	case ASP_HEAD_MIDDLE:
	case ASP_HEAD_TOP:

		path = format(`data/sprite/head/%u_%smale.asp`, r.id, r.gender ? null : `fe`);
		kpath = format(`data/sprite/악세사리/%1$s/%1$s_%2$s`, r.gender.koreanSex, ROdb.hatOf(r.id));

		break;

	/*case ASP_WEAPON:
		auto job = r.jobId.baseClass;
		auto s = weaponTable[r.id]; // or id ???

		path = format(`data/sprite/weapon/%u_%u_%smale.asp`, job, r.id, r.gender ? null : `fe`);
		kpath = format(`data/sprite/인간족/%1$s/%1$s_%2$s_%3$s`, jobTable[job].name, r.gender.sexToString, s);*/
	}

	if(path.length)
	{
		try
		{
			string s;

			if(r.type == ASP_HEAD && r.palette)
			{
				s = `:` ~ id.to!string ~ `_` ~ r.gender.koreanSex ~ `_` ~ r.palette.to!string;
			}

			auto asp = convert!AspFile(format(`%s:%u%s`, kpath.toLower, r.type, s), path);
			res = new SpriteObject;

			res.mh = new MeshHolder(asp.data);
			res.spr = asp.spr;
		}
		catch(Exception e)
		{
			logger.error(e.msg);
		}
	}

	return res;
}
