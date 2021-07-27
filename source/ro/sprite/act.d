module ro.sprite.act;
import std.conv, std.math, std.array, std.stdio, std.string, std.algorithm, stb.image, perfontain, perfontain.misc,
	perfontain.nodes.sprite, perfontain.math.matrix, ro.sprite.spr, ro.conv.asp, utile.except;

struct ActSprite
{
	int x, y, idx, flags;
	Color color;

	float sx;
	@(IgnoreIf!(e => e.input.ver < 0x204), Default!(e => e.that.sx)) float sy;

	int rot;
	uint type;

	@(IgnoreIf!(e => e.input.ver < 0x205)) ubyte[8] waste;
}

struct ActExtra
{
	int unk;
	Vector2i pos;
	int unk2;
}

struct ActFrame
{
	@(Skip!(_ => 32), ArrayLength!uint) ActSprite[] parts;

	int eventId;

	@(IgnoreIf!(e => e.input.ver < 0x203)) uint hasExtra;
	@(IgnoreIf!(e => !e.that.hasExtra)) ActExtra extra;
}

struct ActAction
{
	@(ArrayLength!uint) ActFrame[] frames;
}

struct ActSound
{
	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] path;
}

struct ActFile
{
	static immutable char[2] bom = `AC`;
	@(Validate!(e => e.that.ver > 0x200 && e.that.ver < 0x206)) ushort ver;

	ushort cnt;
	@(Skip!(_ => 10), ArrayLength!(e => e.that.cnt)) ActAction[] acts;

	@(ArrayLength!uint) ActSound[] sounds;
	@(IgnoreIf!(e => e.that.ver < 0x202), ArrayLength!(e => e.that.cnt)) float[] delays;
}

auto imageOf(ref ImageInfo info, in ActSprite s)
{
	auto res = (s.type & 1 ? info.pals : 0) + s.idx;

	res < info.images.length || throwError(`image is out of range`); // TODO: INFO
	return &info.images[res];
}
