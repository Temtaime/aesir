module ro.map.gat;
import utile.binary.attrs;

enum Cell
{
	None = 1,
	Walkable = 2,
	Water = 4,
	Snipable = 8,
}

static immutable ubyte[7] cellType = [
	Cell.Walkable | Cell.Snipable, // walkable ground
	Cell.None, // non-Walkable ground
	Cell.Walkable | Cell.Snipable, // ???
	Cell.Walkable | Cell.Snipable | Cell.Water, // walkable water
	Cell.Walkable | Cell.Snipable, // ???
	Cell.Snipable, // gat (snipable)
	Cell.Walkable | Cell.Snipable, // ???
];

struct GatFile
{
	static immutable char[4] bom = `GRAT`;
	ushort ver; // TODO: versions ???

	uint width, height;
	@(ArrayLength!(e => e.that.width * e.that.height)) GatCell[] cells;
}

struct GatCell
{
	float[4] heights;
	uint type; // TODO: CHECK < 7
}
