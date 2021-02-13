module perfontain.managers.hotkey;

import std, perfontain;

final class HotkeyManager
{
	this()
	{
		PE.onKey.permanent(&onKey);
	}

	void update(string name, SDL_Keycode[] keys...)
	{
		auto e = _arr.find!(a => a.name == name);
		e.length || throwError!`trying to update unknown hotkey: %s`(name);

		//PE.settings.hotkeys[name] = e[0].keys = keys.dup;
	}

	auto add(Hotkey h, bool permanent = true)
	{
		auto e = new Hotkey(h.tupleof);
		_arr ~= e;

		if (auto n = e.name)
		{
			// if(auto p = n in PE.settings.hotkeys)
			// {
			// 	e.keys = *p;
			// }
			// else
			// {
			// 	PE.settings.hotkeys[n] = e.keys;
			// }
		}

		return permanent ? null : new ConnectionPoint({
			_arr = _arr.remove(_arr.countUntil(e));
		});
	}

private:
	bool onKey(SDL_Keycode k, bool st)
	{
		if (st)
		{
			foreach (h; _arr)
			{
				if (h.keys.isPermutation(PE.window.keys))
				{
					if (h.dg())
					{
						return true;
					}

					break;
				}
			}
		}

		return false;
	}

	Hotkey*[] _arr;
}

struct Hotkey
{
	this(string n, bool delegate() f, SDL_Keycode[] ks...)
	{
		dg = f;
		name = n;
		keys = ks.dup;
	}

	string name;
	bool delegate() dg;
	SDL_Keycode[] keys;
}
