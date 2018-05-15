module ro.map.gnd;

import
		std.math,
		std.conv,
		std.array,
		std.range,
		std.string,
		std.typecons,
		std.algorithm,

		perfontain,
		perfontain.misc,
		perfontain.math,

		ro.grf,
		ro.map,
		ro.conf,
		ro.conv,
		ro.conv.map;


struct GndConverter
{
	this(string path, float level, float height)
	{
		_waterLevel = level;
		_waterHeight = height;

		_gnd = PEfs.read!GndFile(path);
	}

	auto process()
	{
		MeshInfo[] res;
		MeshInfo[32] water;

		auto	tx = (_gnd.width + ROM_SPLIT_MAP - 1) / ROM_SPLIT_MAP,
				ty = (_gnd.height + ROM_SPLIT_MAP - 1) / ROM_SPLIT_MAP;

		foreach(i; 0..tx)
		{
			auto	x = i * ROM_SPLIT_MAP,
					sx = min(_gnd.width - x, ROM_SPLIT_MAP);

			foreach(j; 0..ty)
			{
				auto	y = j * ROM_SPLIT_MAP,
						sy = min(_gnd.height - y, ROM_SPLIT_MAP);

				auto r = processSub(water, cast(ushort)x, cast(ushort)y, cast(ushort)sx, cast(ushort)sy);

				if(r.subs.length)
				{
					res ~= r;
				}
			}
		}

		return tuple(res, water);
	}

private:
	alias Subs = Vertex[][string];
	alias Grid = Surface[][];

	auto surfaceOf(ushort x, ushort y, ubyte idx)
	{
		auto c = _gnd.cell(x, y);
		auto sid = c.surfs[idx];

		if(sid < 0)
		{
			return Surface.init;
		}

		// IDX 0 - горизонтальная поверхность
		// IDX 1 - вертикальная передняя поверхность
		// IDX 2 - вертикальная правая боковая поверхность

		if(idx == 1 && y == _gnd.height - 1 || idx == 2 && x == _gnd.width - 1)
		{
			// для передней поверхности необходима клетка перед ней || для боковой поверхности необходима клетка правее нее
			return Surface.init;
		}

		auto sur = &_gnd.surs[sid];

		Surface res =
		{
			tex: _gnd.texs[sur.texId].name.convertName
		};

		foreach(i, ref v; res.va)
		{
			float pz;

			final switch(idx)
			{
			case 0:
				pz = c.heights[i];
				break;

			case 1:
				if(i < 2)
				{
					pz = c.heights[i + 2];
				}
				else
				{
					pz = _gnd.cell(x, y + 1).heights[i - 2];
				}

				break;

			case 2:
				switch(i)
				{
				case 0:
					pz = c.heights[3];
					break;

				case 1:
					pz = c.heights[1];
					break;

				case 2:
					pz = _gnd.cell(x + 1, y).heights[2];
					break;

				default:
					pz = _gnd.cell(x + 1, y).heights[0];
				}
			}

			auto pos = posArray[idx];

			v.x = pos[0][i] + x;
			v.y = pz / -10;
			v.z = -(pos[1][i] + y);

			v.p *= 10 / ROM_SCALE_DIV;

			v.u = sur.u[i];
			v.v = sur.v[i];
		}

		return res;
	}

	void combineImpl(Grid mg, ushort ei, ushort ej, ushort js = 0, byte d = 1, bool combineY = false)
	{
		foreach(ushort i; 0..ei)
		{
			for(ushort j = js; j != ej; j += d)
			{
				auto x = j, y = i;

				if(combineY)
				{
					swap(x, y);
				}

				auto	a = &mg[x][y],
						b = combineY ? &mg[x][y + d] : &mg[x + 1][y];

				combineCells(a, b, combineY, d < 0);
			}
		}
	}

	void optimizeGrid(Grid mg, ubyte side)
	{
		auto	sx = cast(ushort)mg.length,
				sy = cast(ushort)mg[0].length;

		final switch(side)
		{
		case 0:
			combineImpl(mg, sx, cast(ushort)(sy - 1), 0, 1, true);
			combineImpl(mg, sy, cast(ushort)(sx - 1));
			break;

		case 1:
			combineImpl(mg, sy, cast(ushort)(sx - 1));
			break;

		case 2:
			combineImpl(mg, sx, 0, cast(ushort)(sy - 1), -1, true);
		}
	}

	auto processSub(ref MeshInfo[32] water, ushort x, ushort y, ushort sx, ushort sy)
	{
		Subs mi;

		foreach(ubyte s; 0..3)
		{
			auto grid = createArray!Surface(sx, sy);

			foreach(j; 0..sy)
			foreach(i; 0..sx)
			{
				auto	u = cast(ushort)(i + x),
						v = cast(ushort)(j + y);

				auto r = &(grid[i][j] = surfaceOf(u, v, s));

				if(r.tex)
				{
					if(r.va[].any!(a => a.y < _waterLevel + _waterHeight))
					{
						if(!water[0].subs)
						{
							water.each!((ref a) => a.subs ~= SubMeshInfo.init);
						}

						auto vs = r.va;
						auto arr = vs.toByte;
						auto t = ROM_SCALE_DIV;

						vs[0].t = Vector2((u + 0) % t / t, (v + 0) % t / t);
						vs[1].t = Vector2((u + 1) % t / t, (v + 0) % t / t);
						vs[2].t = Vector2((u + 0) % t / t, (v + 1) % t / t);
						vs[3].t = Vector2((u + 1) % t / t, (v + 1) % t / t);

						if(!vs[1].t.x) vs[1].t.x = 1;
						if(!vs[2].t.y) vs[2].t.y = 1;

						if(!vs[3].t.x) vs[3].t.x = 1;
						if(!vs[3].t.y) vs[3].t.y = 1;

						vs.each!((ref a) => a.y = _waterLevel);
						water.each!((ref a) => a.subs[0].data.vertices ~= arr);
					}
				}
			}

			static if(ROM_OPTIMIZE_GRID)
			{
				optimizeGrid(grid, s);
			}

			foreach(ref c; grid.joiner.filter!(a => a.tex.length))
			{
				mi[c.tex] ~= c.va;
			}
		}

		MeshInfo mm;

		foreach(t, vs; mi)
		{
			SubMeshInfo sm =
			{
				tex: RomConverter.imageOf(`data/texture/` ~ t)
			};

			with(sm.data)
			{
				vs = vs
						.chunks(4)
						.map!(a => chain(a[0..3], a[1..4].retro))
						.join;

				vertices = vs.toByte;
				indices = makeIndices(cast(uint)vs.length / 3);

				clear;
				//minimize;
				//unify;

				if(indices.length)
				{
					mm.subs ~= sm;
				}
			}
		}

		return mm;
	}

	static combineCells(Surface *a, Surface *b, bool combineY, bool lastSide)
	{
		if(b.tex != a.tex || !a.tex.length) return;

		// drop tex's coord check for black texture
		auto compCoord = icmp(a.tex, `backside.bmp`) != 0;

		auto	va = a.va[],
				vb = b.va[];

		ubyte v_21, v_12;

		if(lastSide || !combineY)
		{
			v_21 = 1;
			v_12 = 2;
		}
		else
		{
			v_21 = 2;
			v_12 = 1;
		}

		// positions check
		if(!compareCoords(va[v_21].p, vb[0].p) || !compareCoords(va[3].p, vb[v_12].p)) return;

		// surface check
		if(!arePointsOnOneLine(va[0].p, va[v_21].p, vb[v_21].p) || !arePointsOnOneLine(va[v_12].p, va[3].p, vb[3].p)) return;

		if(compCoord)
		{
			// texture coords check
			if(!compareCoords(va[v_21].t, vb[0].t) || !compareCoords(va[3].t, vb[v_12].t)) return;

			bool sw;
			auto f = va[v_21].v - va[0].v;

			if(valueEqual(f, 0))
			{
				sw = true;
				f = va[v_21].u - va[0].u;
			}

			// TODO: CHECK BOTH TEXTURE COORDS: ALL 4 COORDS, NOT ONLY 1

			// delta divider
			auto div = lastSide ? va[1].z - va[0].z : (combineY ? va[0].z - va[2].z : va[1].x - va[0].x);

			// calc a delta
			f /= div / 2;

			if(sw)
			{
				if(!valueEqual(va[v_21].u + f, vb[v_21].u)) return;
			}
			else
			{
				if(!valueEqual(va[v_21].v + f, vb[v_21].v)) return;
			}
		}

		vb[0] = va[0];
		vb[v_12] = va[v_12];

		if(!compCoord)
		{
			vb[0].t = Vector2(0, 0);
			vb[1].t = Vector2(1, 0);
			vb[2].t = Vector2(0, 1);
			vb[3].t = Vector2(1, 1);
		}

		a.tex = null;
	}

	GndFile _gnd;

	float	_waterLevel,
			_waterHeight;
}

// TODO: MOVE ALL THESE FUNCTIONS

auto toInts(in float[] arr)
{
	return arr.map!(a => cast(int)lrint(a * 100)).array;
}

bool compareCoords(T)(ref in T a, ref in T b)
{
	return a.flat.toInts[] == b.flat.toInts[];
}

private:

struct GndFile
{
	static immutable
	{
		char[4] magic = `GRGN`;
		ushort ver = 0x701;
	}

	uint
			width,
			height;

	static immutable float prop = 10;

	uint
			texturesCount,
			texturePathLen;

	@(`length`, `texturesCount`) GndTexture[] texs;

	uint
			lightsCount,
			gridWidth,
			gridHeight,
			gridCells;

	@(`length`, `lightsCount`) GndLightData[] ld;

	@(`uint`) GndSurface[] surs;
	@(`length`, `height * width`) GndCell[] cells;

	const cell(uint x, uint y)
	{
		return &cells[y * width + x];
	}
}

struct GndTexture
{
	@(`length`, `STRUCT.texturePathLen`) char[] name;
}

struct GndColor
{
	ubyte r, g, b;
}

struct GndLightData
{
	ubyte[8][8] brightness;
	ubyte[3][8][8] c; // TODO: COLOR
}

struct GndSurface
{
	float[4] u, v;

	ushort texId;
	short lightmapId;

	ubyte b, g, r, a;
}

struct GndCell
{
	float[4] heights;
	int[3] surfs;
}

struct Surface
{
	string tex;
	Vertex[4] va;
}

static immutable ubyte[4][2][3] posArray =
[
	/**
	2 3
	0 1
	**/
	[
		[ 0, 1, 0, 1 ],
		[ 0, 0, 1, 1 ]
	],

	[
		[ 0, 1, 0, 1 ],
		[ 1, 1, 1, 1 ],
	],

	[
		[ 1, 1, 1, 1 ],
		[ 1, 0, 1, 0 ],
	]
];
