module perfontain.nodes.effect;

import

		std.math,
		std.stdio,
		std.range,

		perfontain,
		perfontain.nodes,

		perfontain.misc,
		perfontain.misc.rc,

		perfontain.math.matrix,

		ro.str,
		rocl.game;


final class EffectNode : Node
{
	this(AafFile aa)
	{
		_aa = aa;
		_mh = new MeshHolder(_aa.data);
		_start = PE.tick;

		PE.scene.scene.node.childs ~= this;
	}

	~this()
	{
		RO.effects.onRemove(this);
	}

	override void draw(in DrawInfo *di)
	{
		auto cam = PEscene.camera;

		//matrix = Matrix4.translate(25, 20, -20) * Matrix4.scale(Vector3(0.5));

		auto mat = cam._inversed * matrix * di.matrix;

		auto f = &_aa.frames[(PE._tick - _start) * _aa.fps / 1000 % $];

		//writeln(`-----------------------`);

		foreach(ref a; f.anims)
		{
			auto m = PE.render.alloc;

			//writefln(`%s %s`, a.mesh, a.c);

			m.mh = _mh;
			m.color = a.c;
			m.matrix = mat;
			m.id = a.mesh;
			m.blendingMode = a.blendingMode;
			m.flags = DI_NO_DEPTH; // TODO: CW ???

			m.lightStart = m.lightEnd = 0;
		}
	}

	void remove()
	{
		PE.scene.scene.node.childs.remove(this);
	}

	const duration()
	{
		return cast(uint)_aa.frames.length * 1000 / _aa.fps;
	}

private:
	uint _start;

	RC!MeshHolder _mh;
	AafFile _aa;
}
