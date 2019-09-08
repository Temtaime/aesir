module ro.conv.map;

import
		std,

		perfontain,

		ro.map,
		ro.grf,
		ro.conf,
		ro.conv,

		utils.logger;


final class RomConverter : Converter
{
	this(string n)
	{
		_rsw = PEfs.read!RswFile(`data/` ~ n ~ `.rsw`);
		_gat = PEfs.read!GatFile(`data/` ~ _rsw.gat.convertName);

		_name = n;
		_mapTranslation = Vector3(_gat.width / 2f, DELTA_UP, _gat.height / 2f);
	}

	override const(void)[] process()
	{
		RomFile res;

		processGround(res);
		processLights(res);
		processWaterParam(res);
		processFloorObjects(res);
		processLightsIndices(res);
		processFogEntries(res);

		return res.binaryWrite;
	}

private:
	auto objects(string Type)()
	{
		return _rsw.objects
							.filter!(a => a.type == mixin(`RswObjectType.` ~ Type))
							.map!(a => mixin(`a.` ~ Type));
	}

	void processGround(ref RomFile f)
	{
		with(f.ground)
		{
			size = Vector2s(_gat.width, _gat.height);

			flags = cellType
							.dup
							.indexed(_gat.cells.map!(a => a.type))
							.array;

			heights = _gat
							.cells
							.map!((ref a) => a.heights[])
							.join;
		}
	}

	auto processFloor(ref RomFile f)
	{
		auto res = GndConverter(`data/` ~ _rsw.gnd.convertName, f.water.level, f.water.height).process;

		f.floor = res[0].map!(a => RomFloor(a.calcBBox)).array;
		f.floor.each!((ref a) => _lights.push(a.box));

		auto water = res[1];

		if(water[0].subs)
		{
			foreach(i, ref w; water)
			{
				auto n = format(`data/texture/워터/water%u%02u.jpg`, f.water.type, i);
				w.subs[0].tex = new Image(PEfs.get(n));

				with(w.subs[0].data)
				{
					auto vs = asVertexes
										.chunks(4)
										.map!(a => chain(a[0..3], a[1..4].retro)) // TODO: COMMON FUNC
										.join;

					vertices = vs.toByte;
					indices = makeIndices(cast(uint)vs.length / 3);
				}
			}

			f.waterData = makeHolderCreator(water, RENDER_SCENE, MH_DXT).process;
		}

		return res[0];
	}

	auto processWaterParam(ref RomFile f)
	{
		f.water.level = -_rsw.waterLevel / ROM_SCALE_DIV;
		f.water.height = _rsw.waterHeight / ROM_SCALE_DIV;

		f.water.speed = _rsw.waterSpeed;
		f.water.pitch = _rsw.waterPitch;
		f.water.animSpeed = _rsw.waterAnimSpeed;

		f.water.type = cast(ubyte)_rsw.waterType;
	}

	void processFloorObjects(ref RomFile f)
	{
		auto poses = makeObjects;
		auto objs = poses.keys;

		{
			auto arr =	processFloor(f) ~
						objs.map!(a => meshesOf(*a)).join; // TODO: HACK

			f.objectsData = makeHolderCreator(arr, RENDER_SCENE, MH_DXT).process; // TODO: CONFIG
		}

		foreach(id, r; objs)
		{
			auto bb = calcBBox(r.mesh);
			auto ps = poses[r];

			foreach(ref m; ps)
			{
				f.poses ~= RomPose(m, bb * (r.trans * m), 0, 0, cast(ushort)id);

				_lights.push(f.poses.back.box);
			}
		}

		auto id = cast(ushort)f.floor.length;
		f.nodes = objs.map!(a => nodeOf(id, *a)).array;
	}

	static
	{
		RomNode nodeOf(ref ushort id, ref in RsmObject r)
		{
			RomNode res;

			res.id = id++;
			res.trans = r.trans;
			res.oris = r.oris.constAway;

			res.childs = r.childs.map!((ref a) => nodeOf(id, a)).array;
			return res;
		}

		MeshInfo[] meshesOf(ref in RsmObject r)
		{
			return cast()r.mesh ~ r.childs.map!(a => meshesOf(a)).join;
		}
	}

	auto makeObjects()
	{
		uint k;
		Matrix4[][RsmObject *] res;

		foreach(ref r; objects!`model`)
		{
			auto name = r.fileName.convertName;
			auto negScale = r.scale.fold!((a, b) => a * b) < 0;

			auto mat = Matrix4.scale(r.scale / ROM_SCALE_DIV)
						* Matrix4.rotate(r.rot * TO_RAD)
						* Matrix4.translate(r.pos / ROM_SCALE_DIV + _mapTranslation + Vector3(0, DELTA_UP * (k++ % 4), 0))
						* coordsConv;

			//if(name != "나무잡초꽃/나무02.rsm") continue;
			//if(name != "나무잡초꽃/덤불01.rsm") continue;

			//if(name != `eclage/타워_테이블01.rsm`) continue;
			//if(name != `para/mora_01.rsm`) continue;

			//if(!name.startsWith(`prontera_re`)) continue;name.writeln;

			try
			{
				res[_objs.get(name, negScale)] ~= mat;
			}
			catch(Exception e)
			{
				logger.error(`can't convert %s: %s`, name, e.msg);
			}
		}

		return res;
	}

	void processLights(ref RomFile f)
	{
		{
			auto dirX = Matrix4.rotateVector(AXIS_X, _rsw.latitude * TO_RAD);
			auto dirY = Matrix4.rotateVector(AXIS_Y, _rsw.longitude * TO_RAD);

			auto dir = dirY * dirX;
			dir.transpose;

			f.lightDir = dir.translation + dir[1].p; // TODO: WHAT IS THIS ?
			f.lightDir.y *= -1;
		}

		f.lights = objects!`light`.map!(a => RomLight(
														(a.pos / ROM_SCALE_DIV + _mapTranslation) * coordsConv,
														a.color,
														a.range / ROM_SCALE_DIV
																				)).array;

		_lights = LightsCalculator(f.lights);

		f.ambient = _rsw.ambient * _rsw.intensity;
		f.diffuse = _rsw.diffuse;
	}

	void processLightsIndices(ref RomFile f)
	{
		auto arr = _lights.calc(f.lightIndices);

		foreach(i, p; arr)
		{
			auto k = cast(int)(i - f.floor.length);

			if(k >= 0)
			{
				f.poses[k].lightStart = p.front;
				f.poses[k].lightEnd = p.back;
			}
			else
			{
				f.floor[i].lightStart = p.front;
				f.floor[i].lightEnd = p.back;
			}
		}

		f.lights = f.lights.indexed(_lights.used).array;
	}

	void processFogEntries(ref RomFile f)
	{
		string[][string] aa;

		{
			string map;

			foreach(s; PEfs.get(`data/fogparametertable.txt`).as!char.assumeUnique.splitter(`#`).map!strip)
			{
				if(s.endsWith(`.rsw`))
				{
					map = s[0..$ - 4];
				}
				else
				{
					aa[map] ~= s;
				}
			}
		}

		auto arr = aa.get(_name, null);

		if(arr.length > 2)
		{
			f.fogFar = arr[1].to!float * 240;
			f.fogNear = arr[0].to!float * 240;

			f.fogColor = Color.fromInt(arr[2].parseNum << 8).tupleof[0..3].Vector3 / 255;
		}
		else
		{
			f.fogFar = 360;
			f.fogNear = 10;
			f.fogColor = Vector3(1);
		}
	}

	const
	{
		string _name;
		Vector3 _mapTranslation;
	}

	RsmObjects _objs;
	LightsCalculator _lights;

	RswFile _rsw;
	GatFile _gat;
}

private:

enum DELTA_UP = -0.005f;

struct RsmObjects
{
	auto get(string name, bool neg)
	{
		auto o = _objs.get(name, null);

		if(!o)
		{
			_objs[name] = o = new S(RsmConverter(name).process);
		}

		if(neg)
		{
			if(!o.neg.mesh.ns)
			{
				swapOrder(o.neg = o.obj);
			}

			return &o.neg;
		}

		return &o.obj;
	}

private:
	void swapOrder(ref RsmObject r)
	{
		swapTrisOrder(r.mesh);
		r.mesh.ns = true;

		each!((ref a) => swapOrder(a))(r.childs = r.childs.dup);
	}

	struct S
	{
		RsmObject obj, neg;
	}

	S *[string] _objs;
}

struct LightsCalculator
{
	this(in RomLight[] lights)
	{
		_arr = lights.map!(a => Light(BBox(a.pos - a.range, a.pos + a.range))).array;
	}

	void push(ref in BBox obj)
	{
		_indices.length++;

		foreach(i, ref s; _arr)
		{
			if(s.box.collision(obj))
			{
				s.used = true;
				_indices.back ~= cast(ushort)i;
			}
		}
	}

	auto used()
	{
		return _arr
					.enumerate
					.filter!(a => a.value.used)
					.map!(a => a.index);
	}

	auto calc(ref ushort[] res)
	{
		// pointers to array elements
		auto index = new ushort[]*[_indices.length];

		// sort to find max lengths
		makeIndex!((a, b) => a.length > b.length)(_indices, index);

		// unused lights
		auto unused = _arr
							.enumerate
							.filter!(a => !a.value.used)
							.map!(a => a.index)
							.array
							.assumeSorted;

		foreach(sub; index.map!(a => *a))
		{
			foreach(ref k; sub)
			{
				k -= unused.lowerBound(k).length;
			}

			if(!res.canFind(sub))
			{
				res ~= sub;
			}
		}

		alias func = (a)
		{
			auto s = a.length ? cast(uint)res.countUntil(a) : 0;
			return [ s, s + cast(uint)a.length ];
		};

		return _indices.map!func.array;
	}

private:
	struct Light
	{
		BBox box;
		bool used;
	}

	Light[] _arr;
	ushort[][] _indices;
}
