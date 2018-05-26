module rocl.render.nodes;

import

		std.math,
		std.stdio,
		std.range,

		perfontain,
		perfontain.math,
		perfontain.nodes,

		perfontain.misc,
		perfontain.misc.rc,

		perfontain.math.matrix,

		ro.str,
		rocl.game;

import rocl.game, rocl.paths, ro.conv, ro.conv.item, ro.conf;


final class ItemNode : Node // TODO: BBOX ON CREATION
{
	this(ushort id)
	{
		HolderSubMesh sub =
		{
			len: 6
		};

		HolderData od =
		{
			type: RENDER_SCENE
		};

		od.meshes ~= HolderMesh(sub.sliceOne.dup);

		{
			auto u = ROdb.itemOf(id).res;
			auto data = convert!RoItem(u, itemPath(u));

			TextureInfo tex =
			{
				TEX_DXT_5,
				[ TextureData(Vector2s(24), data.data) ]
			};

			od.textures ~= tex;
		}

		auto m = Matrix4.scale(Vector3(Vector2(24), 0)) * Matrix4.scale(-SPRITE_PROP, -SPRITE_PROP, 1);

		with(od.data)
		{
			foreach(i; 0..2)
			{
				auto x = -0.5f * (-1) ^^ i;

				foreach(j; 0..2)
				{
					auto y = -0.5f * (-1) ^^ j;

					auto e = Vertex(Vector3(x, y, 0) * m, Vector3(0, 0, 1), Vector2(i, j));
					vertices ~= e.toByte;
				}
			}

			indices = triangleOrder ~ triangleOrderReversed;
			indices[3..$] += 1;

			auto bb = BBox(asVertexes);
			_q = Vector4(bb.min.xy, bb.max.xy);
		}

		_mh = new MeshHolder(od);
	}

	~this()
	{
		RO.items.remove(this);
	}

	override void draw(in DrawInfo *di) // TODO: move in onTick
	{
		if(PE.shadows.passActive)
		{
			return;
		}

		auto cam = PEscene.camera;
		auto mat = cam._inversed * matrix;

		// TODO: OPTIMIZE
		bbox = BBox(Vector3(_q.xy, 0), Vector3(_q.zw, 0)) * mat;

		DrawInfo m;
		auto c = colorWhite;

		m.mh = _mh;
		m.color = c;
		m.matrix = mat;
		m.blendingMode = c.a == 255 ? noBlending : blendingNormal;

		PE.render.toQueue(m);
	}

	auto pickUp()
	{
		auto u = bbox * PE.scene.viewProject;

		auto
				a = project(u.min, PE.window.size),
				b = project(u.max, PE.window.size);

		auto m = PE.window.mpos;

		//log(`%s %s`, a, b);

		if(
			m.x > a.x && m.x < b.x &&
			m.y > b.y && m.y < a.y
									)
		{
			return planeIntersection(a, Vector3(a.x, b.yz), b, Vector3(PE.window.mpos, 1), Vector3(0, 0, -1));
		}
		else
		{
			return 0;
		}
	}

private:
	Vector4 _q;
	RC!MeshHolder _mh;
}

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

		auto f = &_aa.frames[(PE.tick - _start) * _aa.fps / 1000 % $];

		//writeln(`-----------------------`);

		foreach(ref a; f.anims)
		{
			DrawInfo m;

			//writefln(`%s %s`, a.mesh, a.c);

			m.mh = _mh;
			m.color = a.c;
			m.matrix = mat;
			m.id = a.mesh;
			m.blendingMode = a.blendingMode;
			m.flags = DI_NO_DEPTH; // TODO: CW ???

			PE.render.toQueue(m);
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
