module ro.map.rsm.structs;

import
		ro.map,

		perfontain;


struct RsmMesh
{
	char[40]
				name,
				parent;

	@(`uint`) uint[] texIds;

	Matrix3 matrix;
	Vector3 translate1, translate2;

	float angle;
	Vector3 axisVector, scale;

	@(`uint`)
	{
		Vector3[] vertices;
		RsmTextureCoord[] texsInfo;
		RsmSurface[] surs;
		FrameOrientation[] frames;
	}

	debug
		mixin readableToString;
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
	char[40] name;
}

struct RsmFile
{
	static immutable
	{
		char[4] magic = `GRSM`;
		ubyte major = 1;
	}

	@(`validif`, `minor >= 4 && minor <= 5`) ubyte minor;

	uint
			animLen,
			shadeType;

	ubyte alpha;
	@(`skip`, `16`, `uint`) RsmTextureInfo[] texs;

	char[40] main;

	@(`uint`)
	{
		RsmMesh[] meshes;
		@(`ignoreif`, `minor >= 5`, `validif`, `keyFrames.length == 0`) RsmPosKeyFrame[] keyFrames;
		RsmVolumeBox[] boxes;
	}

	@(`ignoreif`, `minor < 5`) static immutable ulong unused;

	debug
		mixin readableToString;
}

struct RsmVolumeBox
{
	Vector3
				size,
				pos,
				rot;

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
