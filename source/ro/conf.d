module ro.conf;

import
		perfontain.math.matrix;


enum
{
	// converter
	ROM_OPTIMIZE_GRID = true,

	ROM_SCALE_DIV = 5f,
	ROM_SPLIT_MAP = 20,

	SPRITE_PROP = 1 / (7 * ROM_SCALE_DIV),

	RES_FILE = `resources.zip`,

	// network
	CLIENT_TYPE = 1,
}

// (x, -y, z) -> (x, y, -z)
static immutable Matrix4 coordsConv;

shared static this()
{
	coordsConv[1] = Vector4(0, -1, 0, 0);
	coordsConv[2] = Vector4(0, 0, -1, 0);
}
