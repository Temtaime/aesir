module rocl.gui.misc;

import
		std,
		perfontain,
		rocl;


void registerHotkeys()
{
	foreach(i; 0..36)
	{
		auto dg =
		{
			uint idx = i, k;

			if(idx > 8)
			{
				auto n = idx - 9;
				auto hotkeys = `qwertyuioasdfghjklzxcvbnm`;

				k = n >= hotkeys.length
										? [ SDLK_COMMA, /*SDLK_PERIOD*/46 ][n - hotkeys.length]
										: SDLK_a + hotkeys[n] - 'a';
			}
			else
			{
				k = SDLK_F1 + idx;
			}

			auto f =
			{
				if(RO.gui.chat.disabled)
				{
					auto e = RO
								.gui
								.hotkeys
								.childs[]
								.map!(a => cast(HotkeyIcon)a)
								.find!(a => RO.gui.hotkeys.posToId(a.pos) == idx);

					if(e.length)
					{
						e[0].use;
						return true;
					}
				}

				return false;
			};

			PE.hotkeys.add(Hotkey(format(`hk_%u`, idx), f, cast(SDL_Keycode)k));
		};

		dg();
	}

	auto acts =
	[
		tuple(`hk_equip`, { RO.gui.status.showOrHide; return true; }, SDLK_e),
		tuple(`hk_skills`, { RO.gui.skills.showOrHide; return true; }, SDLK_s),
		tuple(`hk_settings`, { RO.gui.settings.showOrHide; return true; }, SDLK_o),
		tuple(`hk_inventory`, { RO.gui.inv.showOrHide; return true; }, SDLK_i),
	];

	foreach(e; acts)
	{
		PE.hotkeys.add(Hotkey(e[0], e[1].toDelegate, SDLK_LALT, e[2]));
	}
}

mixin template MakeWindow(T, string Name)
{
	import std.ascii : toUpper;
	enum N = toUpper(Name[0]) ~ Name[1..$];

	mixin(`auto create` ~ N ~ `(A...)(A args)
	{
		if(_` ~ Name ~ `)
		{
			_` ~ Name ~ `.deattach;
		}

		_` ~ Name ~ ` = new T(args);
	}

	void remove` ~ N ~ `()
	{
		if(_` ~ Name ~ `)
		{
			_` ~ Name ~ `.deattach;
			_` ~ Name ~ ` = null;
		}
	}

	@property ` ~ Name ~ `()
	{
		return _` ~ Name ~ `;
	}

	private T _` ~ Name ~ `;`);
}
