module ro.sprite.act;


import
		std.conv,
		std.math,
		std.array,
		std.stdio,
		std.string,
		std.algorithm,

		stb.image,

		perfontain,
		perfontain.misc,
		perfontain.nodes.sprite,
		perfontain.math.matrix,

		ro.sprite.spr,
		ro.conv.asp,

		utils.except;

struct ActSprite
{
	int x, y, idx, flags;
	Color color;

	float sx;
	@(`ignoreif`, `STRUCT.ver < 0x204`, `default`, `sx`) float sy;

	int rot;
	uint type;

	@(`ignoreif`, `STRUCT.ver < 0x205`) ubyte[8] waste;
}

struct ActExtra
{
	int unk;
	Vector2i pos;
	int unk2;
}

struct ActFrame
{
	@(`skip`, `32`, `uint`) ActSprite[] parts;

	int eventId;

	@(`ignoreif`, `STRUCT.ver < 0x203`) uint hasExtra;
	@(`ignoreif`, `!hasExtra`) ActExtra extra;
}

struct ActAction
{
	@(`uint`) ActFrame[] frames;
}

struct ActSound
{
	char[40] path;
}

struct ActFile
{
	static immutable char[2] bom = `AC`;
	@(`validif`, `ver > 0x200 && ver < 0x206`) ushort ver;

	ushort cnt;
	@(`length`, `cnt`, `skip`, `10`) ActAction[] acts;

	@(`uint`) ActSound[] sounds;
	@(`ignoreif`, `ver < 0x202`, `length`, `cnt`) float[] delays;
}

auto imageOf(ref ImageInfo info, ref in ActSprite s)
{
	auto res = (s.type & 1 ? info.pals : 0) + s.idx;

	res < info.images.length || throwError(`image is out of range`); // TODO: INFO
	return &info.images[res];
}
