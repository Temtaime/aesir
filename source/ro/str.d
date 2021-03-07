module ro.str;
import std.uni, std.math, std.array, std.stdio, std.algorithm, perfontain,
	perfontain.misc, perfontain.mesh, perfontain.math, ro.grf, ro.conf, ro.map, ro.conv;

struct AafFile
{
	static immutable
	{
		char[3] bom = `AAF`;
		ubyte ver = 1;
	}

	ubyte fps;

	HolderData data;
	@(ArrayLength!ushort) AafFrame[] frames;
}

struct AafFrame
{
	@(ArrayLength!ushort) AafAnim[] anims;
}

struct AafAnim
{
	Color c;
	ushort mesh;
	ubyte blendingMode;
}

auto toInts(ubyte N = 0, T)(T[] arr)
{
	auto r = arr.as!float
		.map!(a => cast(int)round(a * 1000))
		.array;

	static if (N)
		return r.as!(int[N]);
	else
		return r.as!int;
}

auto intsToType(T)(int[] arr)
{
	return arr.map!(a => float(a) / 1000)
		.array
		.as!T;
}
