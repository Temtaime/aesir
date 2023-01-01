module rocl.entity;

import std.stdio, std.array, std.format, std.algorithm, perfontain, perfontain.math, perfontain.nodes.sprite, ro.grf,
	ro.path, rocl.network, rocl.loaders.asp, ro.db, rocl.game, rocl.entity.actor;
import rocl.network.packets;

public import rocl.entity.misc;

final class EntityManager
{
	~this()
	{
		clearActors;

		if (_self)
		{
			_self.release;
		}
	}

	void process()
	{
		float p;
		cur = null;

		foreach (a; _actors)
		{
			a.process;
			auto r = a.mouseLen;

			if (r != 0 && (r < p || !cur))
			{
				p = r;
				cur = a;
			}
		}

		if (cur)
		{
			auto z = cur.ent.bbox * PE.scene.viewProject;
			auto pos = project(z.min + Vector3(z.size.x / 2, 0, 0), PE.window.size).xy.Vector2s;

			PopupText pt = {pos: pos, msg: cur.cleanName};

			PE.gui.addPopup(pt);
		}
	}

	auto createChar(const scope PkCharData* r, uint bl, bool gender)
	{
		auto pk = ActorInfo(*r);

		pk.bl = bl;
		pk.type = BL_PC;
		pk.gender = gender;

		auto res = new Player(pk);
		res.show;

		add(res);
		return res;
	}

	void onMap(string name, Vector2s pos)
	{
		clearActors;

		if (RO.status.map != name)
		{
			ROres.load(RO.status.map = name);

			if (RO.gui.isGame)
			{
				_self.show;
			}
		}
		else
		{
			RO.items.clear;
		}

		if (!RO.gui.isGame)
		{
			with (ROnet.st)
			{
				_self = createChar(curChar, accountId, gender);
			}

			RO.gui.show(true);
		}

		_self.fix(pos.PosDir);
	}

	auto appear(const scope ActorInfo p)
	{
		auto ac = Actor.create(p);

		ac.fix(p.vpos.PosDir);
		ac.show;

		add(ac);
		return ac;
	}

	void remove(uint bl)
	{
		if (auto p = bl in _actors)
		{
			p.release;
			_actors.remove(bl);
		}
	}

	auto doActor(uint bl, void delegate(Actor) dg)
	{
		if (auto a = _actors.get(bl, null))
		{
			dg(a);
			return true;
		}

		//log(`actor %u is unknown`, bl);
		return false;
	}

	@property self()
	{
		return _self;
	}

	Actor cur;
private:
	void add(Actor a)
	{
		if (auto p = _actors.get(a.bl, null))
		{
			p.release;
		}

		a.acquire;
		_actors[a.bl] = a;
	}

	void clearActors()
	{
		foreach (k, v; _actors.dup)
		{
			if (v !is _self)
			{
				v.release;
				_actors.remove(k);
			}
		}
	}

	Actor _self;
	Actor[uint] _actors;
}
