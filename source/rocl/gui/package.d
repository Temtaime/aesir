module rocl.gui;

import
		std.experimental.all,

		stb.wrapper.image,

		perfontain,

		ro.conv,
		ro.conv.gui,

		rocl.game,
		rocl.paths,
		rocl.gui.misc,
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
		registerHotkeys;
	}

	void show(bool game = false)
	{
		if(game)
		{
			removeCharSelect;

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
				//PE.hotkeys.add(Hotkey(null, { hotkeys.show(!hotkeys.visible); }, SDLK_F12));
			}

			//chat.focus; // TODO: MAKE ONSUBMIT RETURN BOOL AND SEARCH FOR INPUT WINDOW

			PE.scene.camera = new CameraRO(Vector3(0));
		}
		else
		{
			{
				createSettings;

				settings.show(false);

				base = new WinBase;
				inv = new WinInventory;
				chat = new RoChat;

				inv.show(false);
				base.show(false);
				chat.show(false);
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

	RC!ValueManager values;

	RoChat chat;

	WinBase base;
	WinSkills skills;
	WinStatus status;
	WinInventory inv;
	WinHotkeys hotkeys;
	WinTrading trading;

	mixin MakeWindow!(WinShop, `shop`);
	mixin MakeWindow!(WinStorage, `store`);
	mixin MakeWindow!(WinCreation, `creation`);
	mixin MakeWindow!(WinSettings, `settings`);
	mixin MakeWindow!(WinCharSelect, `charSelect`);
	mixin MakeWindow!(WinHotkeySettings, `hotkeySettings`);
private:
	mixin publicProperty!(bool, `isGame`);
}
