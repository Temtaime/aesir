module rocl.entity.misc;
import std.typecons, std.algorithm, perfontain, rocl.loaders.asp;

enum
{
	WALK_SPEED = 150 * 100,
}

struct Walk
{
	Vector2s[] path;
	Vector2 lastPos;

	uint idx, tick;

	ushort lastSpeed;
}

struct PosDir
{
	Vector2s pos;
	ubyte dir;
}

struct ActorInfo
{
	this(T)(in T p)
	{
		foreach (n; __traits(allMembers, typeof(this)))
		{
			static if (n != `__ctor`)
			{
				static if (mixin(`is(typeof(p.` ~ n ~ `))`))
				{
					mixin(n ~ `= p.` ~ n ~ `;`);
				}
			}
		}
	}

	ubyte type;
	int bl;
	short speed;
	short opt1;
	short opt2;
	int option;
	short class_;
	short hairStyle;
	short weapon;
	short shield;
	short headBottom;
	int tick;
	short headTop;
	short headMiddle;
	short hairColor;
	short clothColor;
	short dirHead;
	int robe;
	int guild;
	short emblem;
	short manner;
	int opt3;
	ubyte karma;
	ubyte gender;
	Vector2s vpos;
	ubyte deadSit;
	short level;
	short userFont;
	string name;
}

auto writePos(PosDir v)
{
	ubyte[3] res;

	with (v)
	{
		res[0] = cast(ubyte)(pos.x >> 2);
		res[1] = cast(ubyte)((pos.x << 6) | ((pos.y >> 4) & 0x3f));
		res[2] = cast(ubyte)((pos.y << 4) | (dir & 0xf));
	}

	return res;
}

auto toVec(in ubyte[3] p)
{
	PosDir r;

	with (r)
	{
		pos.x = p[0] << 2 | p[1] >> 6;
		pos.y = (p[1] & 0x3f) << 4 | p[2] >> 4;
		dir = cast(ubyte)(12 - (p[2] & 0xf));
	}

	return r;
}

auto toVec(in ubyte[6] p)
{
	Vector2s pos, to;

	pos.x = ((p[0] & 0xff) << 2) | (p[1] >> 6);
	pos.y = ((p[1] & 0x3f) << 4) | (p[2] >> 4);

	to.x = ((p[2] & 0x0f) << 6) | (p[3] >> 2);
	to.y = ((p[3] & 0x03) << 8) | p[4];

	auto sx = (p[5] & 0xf0) >> 4, sy = p[5] & 0x0f;

	return tuple!(`pos`, `to`, `sx`, `sy`)(pos, to, sx, sy);
}
