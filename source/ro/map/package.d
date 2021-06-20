module ro.map;
import perfontain;

public import ro.map.gat, ro.map.rsm, ro.map.gnd, ro.map.rsw;

struct RomFile
{
	static immutable
	{
		char[3] bom = `ROM`;
		ubyte ver = 19;
	}

	float fogFar, fogNear;
	Vector3 fogColor, ambient, diffuse, lightDir;

	RomWater water;
	RomGround ground;

	@(ArrayLength!ushort) RomFloor[] floor;
	@(ArrayLength!ushort) RomNode[] nodes;
	@(ArrayLength!ushort) RomPose[] poses;
	@(ArrayLength!ushort) RomEffect[] effects;
	@(ArrayLength!ushort) RomLight[] lights;

	HolderData objectsData, waterData;
}

struct RomWater
{
	float pitch, speed, level, height;

	uint animSpeed;
	ubyte type;
}

struct RomGround
{
	Vector2s size;

	@(ArrayLength!(e => e.that.size.x * e.that.size.y)) ubyte[] flags;
	@(ArrayLength!(e => e.that.size.x * e.that.size.y * 4)) float[] heights;
}

struct RomFloor
{
	BBox box;
}

struct RomCell
{
	float height;
	ubyte flags;
}

struct RomNode
{
	@(ArrayLength!ushort) RomNode[] childs;
	@(ArrayLength!ushort) FrameOrientation[] oris;

	Matrix4 trans;
	short id;
}

struct RomPose
{
	Matrix4 pos;
	BBox box;
	ushort id;
}

struct RomLight
{
	Vector3 pos, color;
	float range;
}

struct RomEffect
{
	Vector3 pos;
	ushort id;
}
