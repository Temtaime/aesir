module ro.map.rsw;

import perfontain;

struct RswFile
{
	static immutable char[4] bom = `GRSW`;

	@(Validate!(e => e.that.major && e.that.major <= 2)) ubyte major;
	@(Validate!(e => e.that.major == 1 ? e.that.minor == 9 : e.that.minor <= 1)) ubyte minor;

	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] ini, gnd, gat, scr;

	/// water
	float waterLevel;
	@(Validate!(e => e.that.waterType <= 9)) uint waterType;

	float waterHeight, waterSpeed, waterPitch;

	uint waterAnimSpeed;

	/// light
	uint longitude, latitude;

	Vector3 diffuse, ambient;

	float intensity;

	/// ground
	uint gTop, gBottom, gLeft, gRight;

	@(ArrayLength!uint) RswObject[] objects;
	@ToTheEnd ubyte[] waste;
}

enum RswObjectType
{
	model = 1,
	light,
	sound,
	effect,
}

struct RswObject
{
	uint type;

	@(IgnoreIf!(e => e.that.type != 1)) RswModel model;
	@(IgnoreIf!(e => e.that.type != 2)) RswLight light;
	@(IgnoreIf!(e => e.that.type != 3)) RswSound sound;
	@(IgnoreIf!(e => e.that.type != 4)) RswEffect effect;
}

struct RswModel
{
	@(ArrayLength!(_ => 40), ZeroTerminated) const(ubyte)[] name;

	uint anim_type;
	float anim_speed;
	uint block_type;

	@(ArrayLength!(_ => 80), ZeroTerminated) const(ubyte)[] fileName, node;

	Vector3 pos, rot, scale;

	mixin readableToString;
}

struct RswLight
{
	@(ArrayLength!(_ => 80), ZeroTerminated) const(ubyte)[] name;

	Vector3 pos, color;

	float range;
}

struct RswSound
{
	@(ArrayLength!(_ => 80), ZeroTerminated) const(ubyte)[] name, path;

	Vector3 pos;
	float vol;

	uint width, height;

	float range;
	@(IgnoreIf!(e => e.input.major < 2)) float cycle; // ONLY RSW 2.+, FLOAT ???
}

struct RswEffect
{
	@(ArrayLength!(_ => 80), ZeroTerminated) const(ubyte)[] name;

	Vector3 pos;
	uint id;

	float delay;
	float[4] param;
}
