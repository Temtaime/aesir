module rocl.render.water;

import std.math, std.stdio, std.range, perfontain, perfontain.math, perfontain.nodes, perfontain.misc,
	perfontain.misc.rc, perfontain.math.matrix, ro.map, rocl.game;

final class WaterNode : Node
{
	this(ref RomFile f)
	{
		_water = f.water;
		_mh = new MeshHolder(f.waterData);
	}

	override void draw(in DrawInfo* di)
	{
		if (PE.scene.shadowPass)
		{
			return;
		}

		auto tex = cast(ushort)(PE.tick * 60 / 1000 / _water.animSpeed % 32);

		DrawInfo m;
		auto blend = _water.type != 4 && _water.type != 6;

		m.mh = _mh;
		m.color = blend ? Color(255, 255, 255, 150) : colorWhite;
		m.matrix = matrix * di.matrix;
		m.id = tex;
		m.blendingMode = blend ? blendingNormal : noBlending;
		m.flags = DI_NO_DEPTH;

		PE.render.toQueue(m);
	}

private:
	RomWater _water;
	RC!MeshHolder _mh;
}
