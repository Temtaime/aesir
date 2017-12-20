module perfontain.managers.hotkey;

import
		std.array,
		std.algorithm,

		perfontain;


final class HotkeyManager
{
	auto add(in Hotkey *h, bool permanent = true)
	{
		_arr ~= h;

		if(permanent)
		{
			return null;
		}

		auto dg =
		{
			_arr = _arr.remove(_arr.countUntil(h));
		};

		return new ConnectionPoint(dg);
	}

	void onPress(SDL_Scancode c)
	{
		foreach(h; _arr.filter!(a => a.keys.canFind(c)))
		{
			if(h.keys.all!(a => PE.window.keys[a]))
			{
				h.dg();
				break;
			}
		}
	}

private:
	const(Hotkey) *[] _arr;
}

struct Hotkey
{
	this(void delegate() f, SDL_Scancode[] arr...)
	{
		dg = f;
		keys = arr.dup.sort().array;
	}

const
	void delegate() dg;
	SDL_Scancode[] keys;
}
