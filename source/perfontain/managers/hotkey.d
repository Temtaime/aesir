module perfontain.managers.hotkey;

import
		std.experimental.all,

		perfontain;


final class HotkeyManager
{
	this()
	{
		PE.onKey.permanent(&onKey);
	}

	void update(string name, uint[] keys...)
	{
		auto e = _arr.find!(a => a.name == name);
		e.length || throwError(`trying to update unknown hotkey: %s`, name);

		e[0].keys = keys;
		PE.settings.hotkeys[name] = keys;
	}

	auto add(Hotkey h, bool permanent = true)
	{
		auto e = new Hotkey(h.tupleof);
		_arr ~= e;

		if(auto n = e.name)
		{
			if(auto p = n in PE.settings.hotkeys)
			{
				e.keys = *p;
			}
			else
			{
				PE.settings.hotkeys[n] = e.keys;
			}
		}

		return permanent ? null : new ConnectionPoint({ _arr = _arr.remove(_arr.countUntil(e)); });
	}

private:
	bool onKey(uint k, bool st)
	{
		foreach(h; _arr.filter!(a => a.keys.canFind(k)))
		{
			if(h.keys.all!(a => PE.window.keys[SDL_GetScancodeFromKey(a)])) // TODO: REMAKE
			{
				h.dg();
				return true;
			}
		}

		return false;
	}

	Hotkey*[] _arr;
}

struct Hotkey
{
	this(string n, void delegate() f, uint[] ks...)
	{
		name = n;
		dg = f;
		keys = ks.dup;
	}

	const
	{
		string name;
		void delegate() dg;
	}

	uint[] keys;
}
