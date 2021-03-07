module ro.map.rsm.structs;
import ro.map, perfontain;

struct RsmMesh
{
	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] name, parent;

	@(ArrayLength!uint) uint[] texIds;

	Matrix3 matrix;
	Vector3 translate1, translate2;

	float angle;
	Vector3 axisVector, scale;

	@(ArrayLength!uint)
	{
		Vector3[] vertices;
		RsmTextureCoord[] texsInfo;
		RsmSurface[] surs;
		FrameOrientation[] frames;
	}

	debug mixin readableToString;
}

struct RsmSurface
{
	ushort[3] sv, tv;

	ushort texId;
	ushort padding;

	uint twoSided;
	uint smoothGroup;
}

struct RsmTextureCoord
{
	ubyte a, r, g, b;
	Vector2 t;
}

struct RsmTextureInfo
{
	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] name;
}

struct RsmFile
{
	static immutable
	{
		char[4] magic = `GRSM`;
		ubyte major = 1;
	}

	@Validate!(e => e.that.minor >= 4 && e.that.minor <= 5) ubyte minor;

	uint animLen, shadeType;

	ubyte alpha;
	@(Skip!(_ => 16), ArrayLength!uint) RsmTextureInfo[] texs;

	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] main;

	@ArrayLength!uint
	{
		RsmMesh[] meshes;
		@(IgnoreIf!(e => e.that.minor >= 5), Validate!(e => e.that.keyFrames.length == 0)) RsmPosKeyFrame[] keyFrames;
		RsmVolumeBox[] boxes;
	}

	@(IgnoreIf!(e => e.that.minor < 5)) static immutable ulong unused;

	debug mixin readableToString;
}

struct RsmVolumeBox
{
	Vector3 size, pos, rot;

	uint flags;
}

struct RsmPosKeyFrame
{
	//uint frame;
	//Vector3 pos;
	ulong data;
	uint flags;
	ulong data2;
}
