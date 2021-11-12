module rocl.gui;
import std, stb.image, perfontain, ro.conv, ro.conv.gui, rocl.game, rocl.paths, rocl.gui.misc, rocl.network.packets,
	rocl.controls, rocl.controls.chat, rocl.controls.status, rocl.controls.numbers, rocl.status.item,
	rocl.controls.charselect, rocl.controls.hotkeysettings, rocl.controller.npc, rocl.status, utile.except;

struct IconCache
{
	auto get(Item m)
	{
		auto res = m.data.res;
		return _aa.require(res, makeTex(res));
	}

	auto get(Skill sk)
	{
		auto res = sk.name;
		return _aa.require(res, makeTex(res));
	}

	~this()
	{
		_aa.values.each!(a => a.release);
	}

private:
	auto makeTex(string res)
	{
		auto tex = makeIconTex(res);
		tex.acquire;
		return tex;
	}

	Texture[string] _aa;
}

final class GuiManager
{
	this()
	{
		with (PE.fonts)
		{
			//big = new Font(FONT_FILE, 12);
			base = new Font(FONT_FILE, 12);
			small = new Font(FONT_FILE, 8);
		}

		values = new ValueManager;
		registerHotkeys;
	}

	~this()
	{
		//inv.destroy;
	}

	void removeCharSelect()
	{
		_cd = null;
	}

	void createCharSelect(in PkCharData* data)
	{
		_cd = data;
	}

	void draw()
	{
		if (showSettings)
			settings.draw(isViewer);

		if (isViewer)
			return;

		if (_cd)
			charSelect.draw(_cd);

		if (login)
			login.draw;
		else
		{
			if (_isGame)
			{
				npc.draw;
				inv.draw;
				chat.draw;
				status.draw;
				skills.draw;

				if (shop)
					shop.draw;

				kafra.draw;
			}
		}
	}

	void show(bool game = false)
	{
		if (game)
		{
			removeCharSelect;

			with (ROnet.st.curChar)
			{
				RO.status.jlvl.value = cast(short)jobLvl; // TODO: WTF int
				RO.status.blvl.value = baseLvl;

				RO.status.param(SP_ZENY).value = zeny;
				RO.status.param(SP_STATUSPOINT).value = statPoints;
			}

			inv = new WinInventory;
			kafra = new WinKafra;

			//status.show;

			//skills = new WinSkills;
			//hotkeys = new WinHotkeys;

			//status.show(false);
			//skills.show(false);

			//hotkeys.show(false);

			//chat.focus; // TODO: MAKE ONSUBMIT RETURN BOOL AND SEARCH FOR INPUT WINDOW

			PE.scene.camera = new CameraRO(Vector3(0));
		}
		else
		{
			//createSettings;
			//settings.hide;

			base = new WinBase;
			login = new WinLogin;

			// inv.show(false);
			// base.show(false);
			// chat.show(false);
			//settings.show(false);

			auto p = Vector3(265.44, 61.420, -128.0), d = Vector3(-0.034, -0.639, -0.768);

			auto c = new CameraFPS(p, p + d);
			c.fixed = true;

			PE.scene.camera = c;
		}

		_isGame = game;
	}

	RC!ValueManager values;

	RoChat chat;

	NpcController npc;

	WinBase base;
	WinSkills skills;
	WinStatus status;
	WinHotkeys hotkeys;
	IconCache iconCache;
	WinCharSelect charSelect;

	WinSettings settings;

	RC!WinShop shop;
	RC!WinLogin login;

	RC!WinKafra kafra;
	RC!WinInventory inv;

	//mixin MakeWindow!(WinStorage, `store`);
	//mixin MakeWindow!(WinTrading, `trading`);
	//mixin MakeWindow!(WinCreation, `creation`);
	//mixin MakeWindow!(WinSettings, `settings`);
	//mixin MakeWindow!(WinCharSelect, `charSelect`);
	//mixin MakeWindow!(WinHotkeySettings, `hotkeySettings`);

	bool isViewer, showSettings;
private:
	mixin publicProperty!(bool, `isGame`);

	const(PkCharData)* _cd;
}
