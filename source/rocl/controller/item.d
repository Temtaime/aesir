module rocl.controller.item;

import
		std.array,
		std.typecons,
		std.algorithm,

		perfontain,
		perfontain.math,

		rocl.game,
		rocl.network,

		rocl.render.nodes;


final class ItemController
{
	bool pickUp()
	{
		auto r = _aa
						.byKeyValue
						.map!(a => tuple(a.key, a.value.pickUp))
						.filter!(a => !!a[1])
						.array
						.sort!((a, b) => a[1] < b[1]);

		if(r.empty)
		{
			return false;
		}

		ROnet.pickUp(r.front[0]);
		return true;
	}

	void add(ref in Pk084b p)
	{
		if(p.id in _aa)
		{
			remove(p.id);
		}

		auto n = new ItemNode(p.nameId);
		auto pos = Vector2(p.x, p.y) + Vector2(p.subX, p.subY) / 12;

		n.matrix.translation = Vector3(pos.x, ROres.heightOf(pos.Vector2), -pos.y);

		_aa[p.id] = n;
		PEscene.scene.node.childs ~= n;
	}

	void clear()
	{
		_aa.keys.each!(a => remove(a));
	}

	void remove(uint id)
	{
		if(auto p = id in _aa)
		{
			PEscene.scene.node.childs.remove(*p);
			_aa.remove(id);
		}
	}

	void remove(ItemNode n) // TODO: PACKAGE
	{
		foreach(k, v; _aa)
		{
			if(v == n)
			{
				_aa.remove(k);
				break;
			}
		}
	}

private:
	ItemNode[uint] _aa;
}
