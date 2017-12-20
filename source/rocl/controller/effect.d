module rocl.controller.effect;

import
		std.format,
		std.algorithm,

		perfontain,
		perfontain.nodes.effect,

		ro.str,
		ro.conv,

		rocl.game,
		rocl.entity.visual;


final class EffectController
{
	this()
	{
		PE.timers.add(&onTick, 0, 0);
	}

	void onRemove(EffectNode e)
	{
		_arr = _arr.remove(_arr.countUntil!(a => a.n is e));
	}

	void addSkill(uint id, Vector2s pos)
	{
		auto e = ROdb.query!uint(format(`select main from sk_effects join skills using(name) where id = %u;`, id));

		if(e.length)
		{
			add(e[0][0], pos.Vector2);
		}
	}

	void add(uint id, Vector2 pos)
	{
		string n;

		{
			auto r = ROdb.query!(string, uint)(format(`select name, rnd from effects where id = %u;`, id));

			if(r.length)
			{
				auto e = r[0];
				n = e[1] ? format(e[0], 1) : e[0];
			}
			else
			{
				log.warning(`unknown effect %u`, id);
				return;
			}
		}

		try
		{
			auto s = convert!AafFile(n, n ~ `.aaf`);
			auto e = new EffectNode(s);

			e.matrix.translation = Vector3(pos.x + 0.5, ROres.heightOf(pos) + 5, -(pos.y + 0.5));

			_arr ~= S(null, e, PE.tick + e.duration);
		}
		catch(Exception e)
		{
			log.error(`effect %u: %s`, id, e.msg);
		}
	}

private:
	void onTick()
	{
		for(uint i; i < _arr.length; )
		{
			auto s = &_arr[i];

			if(PE.tick >= s.end)
			{
				s.n.remove;
			}
			else
			{
				i++;
			}
		}
	}

	struct S
	{
		Entity e;
		EffectNode n;
		uint end;
	}

	S[] _arr;
}
