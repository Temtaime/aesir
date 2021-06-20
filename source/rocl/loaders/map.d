module rocl.loaders.map;
import std.stdio, std.range, std.array, std.algorithm, perfontain, perfontain.opengl, ro.map, ro.conv, rocl.paths,
	ro.conv.map, rocl.render.water;

struct RomLoader
{
	this(string name)
	{
		_rom = new RomConverter(name).convert; // TODO: FIXME _rom.objectsData.atlased != PE.settings.useBindless
	}

	auto process(ref RomGround ground)
	{
		_mh = new MeshHolder(_rom.objectsData);
		ground = _rom.ground;

		auto res = new Scene;
		processLights(res);
		processNodes(res);
		return res;
	}

private:
	void processLights(Scene sc)
	{
		sc.ambient = _rom.ambient;
		sc.diffuse = _rom.diffuse;

		sc.lightDir = _rom.lightDir;
		sc.lights = _rom.lights.map!(a => LightSource(a.pos, a.color, a.range)).array;

		sc.fogFar = _rom.fogFar;
		sc.fogNear = _rom.fogNear;
		sc.fogColor = _rom.fogColor;
	}

	void processNodes(Scene sc)
	{
		auto node = asRC(new Node);

		foreach (i, ref f; _rom.floor)
		{
			auto n = allocateRC!ObjecterNode;

			n.id = cast(ushort)i;
			n.mh = _mh;
			n.bbox = f.box;

			node.childs ~= n;
		}

		processObjects(node);
		node.recalcBBox;

		if (_rom.waterData.meshes)
		{
			auto n = allocateRC!WaterNode(_rom);
			n.bbox = node.bbox;

			node.childs ~= n;
		}

		sc.node = new Node;
		sc.node.childs ~= new OctreeNode(node);
		sc.node.bbox = node.bbox;
	}

	void processObjects(Node node)
	{
		RCArray!ObjecterNode nodes = _rom.nodes.map!((ref a) => makeNode(a)).array;

		foreach (ref r; _rom.poses)
		{
			auto n = allocateRC!ObjecterNode;
			auto s = nodes[r.id];

			n.id = s.id;
			n.mh = _mh;

			n.oris = s.oris;
			n.matrix = s.matrix * r.pos;

			n.bbox = r.box;
			n.childs = s.childs;

			node.childs ~= n;
		}
	}

	ObjecterNode makeNode(ref RomNode n)
	{
		auto res = allocateRC!ObjecterNode;

		res.mh = _mh;
		res.id = n.id;

		res.oris = n.oris;
		res.matrix = n.trans;

		foreach (c; n.childs.map!((ref a) => makeNode(a)))
		{
			res.childs ~= c;
		}

		return res;
	}

	RomFile _rom;
	RC!MeshHolder _mh;
}
