module rocl.controls.hotkeysettings;

import
		std,

		perfontain,

		ro.conv.gui,

		rocl,
		rocl.game;


final:

class WinHotkeySettings : WinBasic2
{
	this()
	{
		super(MSG_HOTKEY_SETTINGS, `hotkeys`);

		{
			auto msgs =
			[
				MSG_SKILLS ~ ` 1-2`,
				MSG_SKILLS ~ ` 3-4`,
				MSG_INTERFACE
			];

			auto e = new TextTabs(main, msgs);

			foreach(i, u; e.tabs)
			{
				if(i < 2)
				{
					foreach(k; 0..18)
					{
						auto n = format(`hk_%u`, i * 18 + k);
						auto r = new HotkeySelector(u, n, format(`Hotkey %u-%u`, i * 2 + k / 9 + 1, k % 9 + 1));

						r.pos = Vector2s(k >= 9 ? r.size.x + 10 : 0, r.size.y * (k % 9) + 4);
					}
				}
				else
				{
					auto acts =
					[
						tuple(MSG_WIN_EQUIP, `hk_equip`),
						tuple(MSG_WIN_SKILLS, `hk_skills`),
						tuple(MSG_WIN_SETTINGS, `hk_settings`),
						tuple(MSG_WIN_INVENTORY, `hk_inventory`),
					];

					auto x = acts.map!(a => cast(short)PE.fonts.base.widthOf(a[0])).reduce!max;

					foreach(k, act; acts)
					{
						auto r = new HotkeySelector(u, act[1], act[0], x);
						r.pos = Vector2s(0, r.size.y * k + 4);
					}
				}
			}

			e.adjust;
		}

		adjust;

		{
			auto b = new Button(this, MSG_OK);

			b.move(this, POS_MAX, -5, bottom, POS_CENTER);
			b.onClick = &RO.gui.removeHotkeySettings;
		}

		center;
	}

	~this()
	{
		childs.clear;
	}
}

class HotkeySelector : GUIElement
{
	this(GUIElement p, string n, string text, short x = -1)
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

			if(x < 0)
			{
				und.moveX(t, POS_ABOVE, 4);
			}
			else
			{
				und.pos.x = x;
			}
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

	bool processKey(SDL_Keycode k, bool st)
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

		FontInfo fi =
		{
			maxWidth: und.size.x
		};

		auto e = new GUIStaticText(und, s, fi);
		e.moveX(und, POS_CENTER);
	}

	static nameOf(SDL_Keycode k)
	{
		return SDL_GetKeyName(k).fromStringz.assumeUnique;
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

	SDL_Keycode[] _keys;
	const string _name;
	RC!ConnectionPoint _cp;
}
