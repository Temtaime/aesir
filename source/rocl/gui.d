module rocl.gui;

import
		std.conv,
		std.range,
		std.format,
		std.string,
		std.random,
		std.algorithm,

		ciema,

		perfontain,

		ro.conv,
		ro.conv.gui,

		rocl.game,
		rocl.paths,
		rocl.network.packets,

		rocl.controls,
		rocl.controls.chat,
		rocl.controls.status,
		rocl.controls.numbers,
		rocl.controls.charselect,
		rocl.controls.hotkeysettings,

		tt.error;


final class GuiManager
{
	this()
	{
		with(PE.fonts)
		{
			//big = new Font(FONT_FILE, 12);
			base = new Font(FONT_FILE, 12);
			small = new Font(FONT_FILE, 8);
		}

		with(PE.gui)
		{
			auto rog = convert!RogFile(null, GUI_PATH);

			holder = new MeshHolder(rog.data);
			sizes = rog.sizes.dup;
		}

		values = new ValueManager;

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

					PE.hotkeys.add(Hotkey(format(`hk_%u`, idx), { idx.log; }, cast(SDL_Keycode)k));
				};

				dg();
			}
		}

		new WinHotkeySettings;

		//PE.onAspect.permanent(&onAspect);
	}

	void show(bool game = false)
	{
		if(game)
		{
			_cs.remove;
			_cs = null;

			inv.show;
			chat.show;
			base.show;

			with(ROnet.st.curChar)
			{
				base.job.lvl = jobLvl;
				base.base.lvl = baseLvl;

				inv.zeny = zeny;
			}

			status = new WinStatus;
			skills = new WinSkills;
			hotkeys = new WinHotkeys;

			status.show(false);
			skills.show(false);

			// TODO: REMOVE
			{
				PE.hotkeys.add(Hotkey(null, { hotkeys.show(!hotkeys.visible); }, SDLK_F12));
			}

			//chat.focus; // TODO: MAKE ONSUBMIT RETURN BOOL AND SEARCH FOR INPUT WINDOW

			PE.scene.camera = new CameraRO(Vector3(0));
		}
		else
		{
			{
				settings = new WinSettings;

				base = new WinBase;
				inv = new WinInventory;
				chat = new RoChat;

				inv.show(false);
				base.show(false);
				chat.show(false);
				settings.show(false);
			}

			auto
					p = Vector3(265.44, 61.420, -128.0),
					d = Vector3(-0.034, -0.639, -0.768);

			auto c = new CameraFPS(p, p + d);

			c.fixed = true;
			PE.scene.camera = c;
		}

		_isGame = game;
	}

	void removeShop()
	{
		if(shop)
		{
			shop.remove;
			shop = null;
		}
	}

	void createShop(uint id)
	{
		if(shop)
		{
			shop.remove;
		}

		shop = new WinShop(id);
	}

	@property store()
	{
		return _store ? _store : (_store = new WinStorage);
	}

	void removeStore()
	{
		if(_store)
		{
			_store.remove;
			_store = null;
		}
	}

	void removeCreation()
	{
		creation.remove;
		creation = null;
	}

	void makeCreation()
	{
		creation = new WinCreation;
	}

	void onStatsChange()
	{
		/*stats.remove;
		stats = new WinStatus;*/
	}

	void removeCs()
	{
		_cs.remove;
		_cs = null;
	}

	void createCharSelect(in PkCharData *data)
	{
		if(_cs)
		{
			_cs.remove;
		}

		_cs = new WinCharSelect(data);
	}

	void msg(string text)
	{
		//PEgui.root.childs ~= createWin!GUI_WIN_MSG(text);
	}

	RC!ValueManager values;

	RoChat chat;

	WinBase base;
	WinShop shop;
	WinSkills skills;
	WinStatus status;
	WinInventory inv;
	WinHotkeys hotkeys;
	WinTrading trading;
	WinCreation creation;
	WinSettings settings;
private:
	mixin publicProperty!(bool, `isGame`);

	void onAspect(float)
	{
		//PE.gui.root.childs.clear;
		//show;
	}

	WinStorage _store;
	WinCharSelect _cs;
	//ScrollableText _chat;
}
