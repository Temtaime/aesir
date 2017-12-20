module ro.map;

import
		perfontain;

public import
				ro.map.gat,
				ro.map.rsm,
				ro.map.gnd,
				ro.map.rsw;

struct RomFile
{
	static immutable
	{
		char[3] bom = `ROM`;
		ubyte ver = 17;
	}

	float
			fogFar,
			fogNear;

	Vector3
				fogColor,
				ambient,
				diffuse,
				lightDir;

	RomGround ground;

	@(`ushort`) RomFloor[] floor;
	@(`ushort`) RomNode[] nodes;
	@(`ushort`) RomPose[] poses;
	@(`ushort`) RomEffect[] effects;

	@(`ushort`) RomLight[] lights;
	@(`uint`) ushort[] lightIndices;

	HolderData objectsData;
}

struct RomGround
{
	Vector2s size;

	@(`length`, `size.x * size.y`) ubyte[] flags;
	@(`length`, `size.x * size.y * 4`) float[] heights;
}

struct RomFloor
{
	BBox box;

	uint
			lightStart,
			lightEnd;
}

struct RomCell
{
	float height;
	ubyte flags;
}

struct RomNode
{
	@(`ushort`) RomNode[] childs;
	@(`ushort`) RomFrameOrientation[] oris;

	Matrix4 trans;
	short id;
}

struct RomFrameOrientation
{
	uint time;
	Quaternion q;
}

struct RomPose
{
	Matrix4 pos;
	BBox box;

	uint
			lightStart,
			lightEnd;

	ushort id;
}

struct RomLight
{
	Vector3
			pos,
			color;

	float range;
}

struct RomEffect
{
	Vector3 pos;
	ushort id;
}
