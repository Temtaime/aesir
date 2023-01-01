module rocl.network.structs;

import	rocl.network.packets,
		perfontain;


struct RoPos
{
	this(Vector2s p, ubyte dir = 0)
	{
		data[0] = cast(ubyte)(p.x >> 2);
		data[1] = cast(ubyte)(p.x << 6 | (p.y >> 4 & 0x3F));
		data[2] = cast(ubyte)(p.y << 4 | (dir & 0xF));
	}

	auto unpack()
	{
		Vector2s res;

		res.x = data[0] << 2 | data[1] >> 6;
		res.y = (data[1] & 0x3F) << 4 | data[2] >> 4;

		return res;
	}

	ubyte[3] data;
}

struct NetStatus
{
	const curChar()
	{
		return &chars[ch];
	}

	const(PkCharData)[] chars;

	uint
			accountId,
			authCode;

	ubyte ch;
	bool gender;
}
