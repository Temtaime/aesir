module rocl.entity.visual;

import
		std.stdio,
		std.array,
		std.algorithm,

		perfontain,
		perfontain.math,

		ro.path,

		rocl.game,
		rocl.controls,
		rocl.loaders.asp,

		rocl.entity.misc,
		rocl.entity.actor;


enum Action : ubyte
{
	idle,
	walk,

	attack,
	attack1,
	attack2,
	attack3,

	readyFight,
	hurt,
	die,

	sit,
	pickup,

	freeze,
	freeze2,

	skill,
	action,
	special,

	perf1,
	perf2,
	perf3,
}

auto actId(ubyte act, byte bl)
{
	with(Action)
	{
		immutable tb = // TODO: DMD BUG
		[
			BL_PC:		[ idle, walk, sit, pickup, readyFight, attack1, hurt, freeze, die, freeze2, attack2, attack3, skill ],
			BL_MOB:		[ idle, walk, attack, hurt, die ],
			BL_PET:		[ idle, walk, attack, hurt, die, special, perf1, perf2, perf3 ],
			BL_NPC_EVT:	[ idle, walk ],
			BL_HOM:		[ idle, walk, attack, hurt, die, attack2, attack3, action ],
		];

		return cast(ubyte)max(tb[bl].countUntil(act), 0);
	}
}

final class Entity : RCounted
{
	this(ushort id, ubyte t, bool gender)
	{
		type = t;
		_node = new SpriteNode;

		add(SPR_BODY, AspLoadInfo(id, 0, ASP_BODY, gender));
		act(Action.idle);

		info = new CharInfo(this);
	}

	~this()
	{
		PEscene.scene.node.childs.remove(_node);
	}

	void head(ubyte d)
	{
		if(type == BL_PC)
		{
			_node.directionHead = d;
		}
	}

	void dir(ubyte d) { _node.direction = d; }

	void show()
	{
		with(PEscene.scene.node)
		{
			assert(childs[].countUntil!(a => a is _node) < 0);

			childs ~= _node;
		}
	}

	auto act(ubyte cur, byte next = -1, ushort time = 0, ushort factor = 0)
	{
		cur = actId(cur, type);

		if(next >= 0)
		{
			next = actId(next, type);
		}

		_node.doAction(cur, next, time, factor);
	}

	ref bbox() const
	{
		return _node.bbox;
	}

	auto mouseLen()
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

	void process()
	{
		with(_walk)
		{
			if(path.length)
			{
				bool e;

				while(tick <= PE.tick)
				{
					auto c = path[idx];

					if(idx == path.length - 1)
					{
						e = true;
						break;
					}

					auto n = path[idx + 1];
					auto v = n - c;

					lastSpeed = cast(ushort)(v.x && v.y ? speed * 14 / 10 : speed);

					tick += lastSpeed;
					idx++;
				}

				auto	c = idx == 1 ? lastPos : path[idx - 1].Vector2,
						n = path[idx].Vector2,
						d = n - c;

				auto td = 1 - max(int(tick - PE.tick), 0f) / lastSpeed;

				//writefln(`%s %s %s %s`, c, n, td, d);

				pose(c + d * td);

				_node.direction = direction(d, true);

				if(e)
				{
					stop;
				}
			}
		}

		info.update;
	}

	void move(Vector2s p, Vector2s to)
	{
		if(p == to)
		{
			return fix(to.PosDir);
		}

		auto pf = PathFinder(ROres.size, (x, y) => ROres.flagsOf(Vector2s(x, y)));

		_walk.path = pf.search(p, to);
		_walk.lastPos = pos2;
		_walk.idx = 0;
		_walk.tick = PE.tick;

		act(Action.walk, -1, 0, cast(ushort)(speed * 100 / 150));
	}

	void fix(const scope PosDir v)
	{
		stop;
		pose(v.pos.Vector2);

		_node.direction = v.dir;
	}

	void add(ubyte idx, const scope AspLoadInfo info)
	{
		auto s = ROres.load(info);

		if(idx == SPR_BODY && !s)
		{
			s = ROres.load(AspLoadInfo(1002));
			s || throwError(`can't load poring`);
		}

		_node.sprites[idx] = s;
	}

	ushort speed;
	const ubyte type;
//package:
	ref pos()
	{
		return _node.matrix.translation;
	}

	auto pos2()
	{
		return Vector2(pos.x - 0.5, -pos.z - 0.5);
	}

	RC!CharInfo info;
private:
	void stop()
	{
		_walk.path = null;
		act(Action.idle);
	}

	void pose(Vector2 p)
	{
		pos = Vector3(p.x + 0.5, ROres.heightOf(p), -(p.y + 0.5));

		if(isMain)
		{
			if(auto c = cast(CameraRO)PE.scene.camera)
			{
				c.pos = pos;
			}
		}
	}

	const isMain()
	{
		if(Actor a = ROent.self)
		{
			return a.ent is this;
		}

		return false;
	}

	RC!SpriteNode _node;
	Walk _walk;
}
