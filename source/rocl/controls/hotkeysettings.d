module rocl.controls.hotkeysettings;

import
		std.experimental.all,

		perfontain,

		rocl;


final:

class WinHotkeySettings : WinBasic2
{
	this()
	{
		super(MSG_HOTKEY_SETTINGS);

		auto e = new TextTabs(main, [ MSG_SKILLS ~ ` 1-2`, MSG_SKILLS ~ ` 3-4`, MSG_INTERFACE ]);

		foreach(i, u; e.tabs)
		{
			if(i < 2)
			{
				foreach(k; 0..18)
				{
					auto n = format(`hk_%u`, i * 18 + k);
					auto r = new HotkeySelector(u, n, format(`Hotkey %u-%u`, i * 2 + k / 9 + 1, k % 9 + 1));

					r.pos = Vector2s(k >= 9 ? r.size.x + 10 : 0, r.size.y * (k % 9) + 4);
					//r.pos.y = cast(short)(r.size.y * k + 4);
				}
			}
			else
			{
				static immutable acts =
				[
				];
			}
		}

		e.adjust;

		main.toChildSize;
		main.pad(10);

		adjust;
		center;
	}

	~this()
	{
		childs.clear;
	}
}

class HotkeySelector : GUIElement
{
	this(GUIElement p, string n, string text)
	{
		super(p);

		{
			auto t = new GUIStaticText(this, text);

			new class Underlined
			{
				this()
				{
					super(this.outer);
				}

				override void onFocus(bool st)
				{
					if(st)
					{
						record(true);
					}
				}

				override void draw(Vector2s p) const
				{
					if(_cp)
					{
						drawQuad(p + pos, size - Vector2s(0, 1), colorGray);
					}

					super.draw(p);
				}
			};

			und.size = Vector2s(120, PE.fonts.base.height + 1);
			und.moveX(t, POS_ABOVE, 4);
		}

		{
			_name = n;

			if(auto arr = n in PE.settings.hotkeys)
			{
				_keys = *arr;
			}
		}

		toChildSize;
		makeText;
	}

	~this()
	{
		PE.settings.hotkeys[_name] = _keys;
	}

private:
	mixin MakeChildRef!(Underlined, `und`, 1);

	void record(bool st)
	{
		if(st)
		{
			_keys = null;
			_cp = PE.onKey.add(&processKey);

			makeText(`?`);
		}
		else
		{
			_cp = null;

			if(!_keys.length)
			{
				makeText;
			}

			PE.hotkeys.update(_name, _keys);
		}
	}

	bool processKey(uint k, bool st)
	{
		if(st && k != SDLK_ESCAPE && _keys.all!(a => specials.canFind(a)))
		{
			_keys ~= k;
			makeText();
		}
		else
		{
			record(false);
		}

		return true;
	}

	void makeText()
	{
		makeText(_keys ? _keys.map!(a => nameOf(a)).join(`+`) : `none`);
	}

	void makeText(string s)
	{
		und.childs.clear;

		auto e = new GUIStaticText(und, s, 0, null, und.size.x);
		e.moveX(und, POS_CENTER);
	}

	static nameOf(uint k)
	{
		return cast(string)SDL_GetKeyName(k).fromStringz;
	}

	static immutable specials =
	[
		SDLK_LALT,
		SDLK_LCTRL,
		SDLK_LSHIFT,

		SDLK_RALT,
		SDLK_RCTRL,
		SDLK_RSHIFT,
	];

	uint[] _keys;
	const string _name;
	RC!ConnectionPoint _cp;
}
