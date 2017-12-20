module perfontain.nodes.sprite;

import
		std.math,
		std.stdio,
		std.range,

		perfontain,
		perfontain.math,
		perfontain.nodes,

		perfontain.misc;

enum
{
	SPR_BODY,
	SPR_HEAD,
	SPR_HEAD_BOTTOM,
	SPR_HEAD_MIDDLE,
	SPR_HEAD_TOP,
	SPR_SHIELD,
	SPR_WEAPON,
	SPR_MAX
}

enum
{
	SPR_STANDING,
	SPR_MOVING,
	SPR_ATTACK,
	SPR_DAMAGING,
	SPR_DEAD,
}

struct SpriteImage
{
	ushort mesh;
	Color color;
}

struct SpriteFrame
{
	@(`ubyte`) SpriteImage[] images;

	Vector4 size;
	Vector2 extra;

	byte event;
}

struct SpriteAction
{
	@(`ushort`) SpriteFrame[] frames;
	ushort delay;
}

struct SpriteEvent
{
	@(`ubyte`) string audio;
}

struct Sprite
{
	@(`ubyte`) SpriteEvent[] events;
	@(`ubyte`) SpriteAction[] actions;
}

final class SpriteObject : RCounted
{
	Sprite spr;
	RC!MeshHolder mh;
}

final class SpriteNode : Node // TODO: BBOX ON CREATION
{
	override void draw(in DrawInfo *di) // TODO: move in onTick
	{
		SpriteObject spr = sprites[0];
		//if(!spr) return;

		auto cam = PEscene.camera;
		auto mat = cam._inversed * matrix;// * Matrix4.translate(0, 0.8, 0);

		if(!PE.shadows.passActive)
		{
			auto v = cam.view;

			auto k = mat * cam.view;
			auto u = 1f;

			k[1][2] += 0.5f / u;
			k[1][3] += u / 50;

			mat = k * cam.view.inversed;
		}

		auto tm = PE._tick - _start;

		if(_time > 0 && tm > _time)
		{
			_action = _next;
			_start = PE._tick;

			tm = _time = 0;
		}

		auto fdir = (direction + cam._udir) % 8;

		auto aa = (_action * 8 + fdir);
		auto a = &spr.spr.actions[aa % $];

		auto frame =	_time > 0
									? tm * cast(uint)a.frames.length / _time
									: tm / (
												_factor
														? a.delay * _factor / 100
														: a.delay
																	);

		auto fs = &a.frames[(directionHead < 0 || _action ? frame : directionHead) % $];

		// TODO: OPTIMIZE
		bbox = BBox(Vector3(fs.size.xy, 0), Vector3(fs.size.zw, 0)) * mat;

		foreach(ref im; fs.images)
		{
			auto m = PE.render.alloc;
			auto c = im.color;

			m.mh = spr.mh;
			m.color = c;
			m.matrix = mat;
			m.id = im.mesh;
			//m.depth = 0.01;
			m.flags = 0;//DI_NO_PROJ;
			m.lightStart = m.lightEnd = 0;
			m.blendingMode = c.a == 255 ? noBlending : blendingNormal;
		}

		foreach_reverse(i, SpriteObject s; sprites[1..$])
		{
			if(!s)
			{
				continue;
			}

			if(fdir >= 3 && fdir <= 5 && (i == SPR_HEAD_MIDDLE - 1 || i == SPR_HEAD_BOTTOM - 1))
			{
				continue;
			}

			auto sa = &s.spr.actions[aa % $];

			auto cnt = cast(ushort)sa.frames.length / 3;
			auto u = &sa.frames[cnt > 1 ? directionHead * 3 + frame % cnt : directionHead];

			auto m2 = u.extra.x.isNaN ? mat : Matrix4.translate(Vector3(fs.extra - u.extra, 0)) * mat;

			bbox += BBox(Vector3(u.size.xy, 0), Vector3(u.size.zw, 0)) * m2;

			foreach(ref im; u.images)
			{
				auto m = PE.render.alloc;

				m.mh = s.mh;
				m.color = im.color;
				m.matrix = m2;
				m.id = im.mesh;
				//m.depth = 0.01;
				m.flags = 0;//DI_NO_PROJ;
				m.lightStart = m.lightEnd = 0;
				m.blendingMode = noBlending;
			}
		}

		if(_event != fs.event)
		{
			_event = fs.event;

			if(_event >= 0)
			{
				auto name = spr.spr.events[_event].audio;

				if(name != `atk`) // ???
				{
					PEaudio.play(`data/wav/` ~ name);
				}
			}
		}
	}

	void doAction(ubyte cur, byte next = -1, ushort time = 0, ushort factor = 0) // TODO: SEPARATE
	{
		if(_action != cur)
		{
			_action = cur;
			_start = PE._tick;
		}

		_next = next;
		_time = time;
		_factor = factor;
	}

	RC!SpriteObject[SPR_MAX] sprites;

	ubyte direction;
	byte directionHead = -1;
private:
	uint _start;

	ushort	_time,
			_factor;

	byte	_action = -1,
			_next = -1,
			_event = -1;
}

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

		auto m = PE.render.alloc;
		auto c = colorWhite;

		m.mh = _mh;
		m.color = c;
		m.matrix = mat;
		m.id = 0;
		m.flags = 0;
		m.lightStart = m.lightEnd = 0;
		m.blendingMode = c.a == 255 ? noBlending : blendingNormal;
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
