module perfontain.managers.gui.misc;

import
		std,

		perfontain;


template MakeChildRef(T, string Name, Idx...)
{
	mixin(`inout(T) ` ~ Name ~ `() inout
	{
		GUIElement e = cast()this;

		foreach(i; Idx)
		{
			auto k = i < 0 ? e.childs.length + i : i;

			if(k >= e.childs.length)
			{
				return null;
			}

			e = e.childs[k];
		}

		return cast(inout(T))e;
	}`);
}

auto calcSize(R)(auto ref R r, bool withPos = true)
{
	Vector2s res;

	foreach(i; 0..2)
	{
		res[i] = cast(short)r.map!(a => withPos ? a.end[i] : a.size[i]).fold!max(0);
	}

	return res;
}
