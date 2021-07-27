module rocl.game;
import std, perfontain, perfontain.misc, ro.db, ro.str, ro.conv, rocl.loaders.asp, rocl, rocl.gui, rocl.status,
	rocl.entity, rocl.network, rocl.controls, rocl.resources, rocl.controller.npc, rocl.controller.item,
	rocl.controller.action, rocl.controller.effect, rocl.rofs;

@property ROfs()
{
	return cast(RoFileSystem)PEfs;
}

@property ref RO()
{
	return Game.instance;
}

@property ROdb()
{
	return RO._db;
}

@property ROent()
{
	return RO._emgr;
}

@property ROres()
{
	return RO._rmgr;
}

@property ROnet()
{
	return RO._pmgr;
}

ref ROnpc() @property
{
	return RO.gui.npc;
}

final class Game
{
	__gshared instance = new Game;

	~this()
	{
		dtors;
	}

	void doInit()
	{
		auto js = readText(`aesir.json`).parseJSON;

		settings.serv = js[`server`].str;
		settings.grfs = js[`grfs`].array.map!(a => a.str).array;

		LANG = cast(ubyte)max(LANGS.countUntil(js[`lang`].str), 0);
	}

	void run(string[] args)
	{
		bool viewer;
		string user, pass, backend;

		getopt(args, `viewer`, &viewer, `user`, &user, `pass`, &pass, `backend`, &backend);

		if (initialize(viewer ? 45 : 15, backend))
		{
			if (viewer)
			{
				//if(std.file.exists(`tmp/map/prontera.rom`)) std.file.remove(`tmp/map/prontera.rom`);
				mapViewer;
			}
			else
			{
				gui.show;

				if (user.length)
				{
					gui.login = null; // TODO: rewrite
					ROnet.login(user, pass);
				}
			}

			PE.work;
		}
	}

	GuiManager gui;
	RoSettings settings;

	Status status;
	ItemController items;
	ActionController action;
	EffectController effects;
package:
	void doExit()
	{
		PE.quit;
	}

private:
	void mapViewer()
	{
		ROres.load(`prontera`);

		//PE.hotkeys.add(Hotkey({ log(`lispsm %s`, PE.shadows.lispsm ^= true); }, SDLK_LCTRL, SDLK_a));
		debug
		{
			PE.hotkeys.add(Hotkey(null, { PEstate.wireframe = !PEstate.wireframe; return true; }, SDLK_F11));
			//PE.hotkeys.add(Hotkey(null, { PE.shadows.tex.toImage.saveToFile(`shadows.tga`, IM_TGA); return true; }, SDLK_F10));
		}

		auto p = Vector3(0, 24.810, 0);
		PEscene.camera = new CameraFPS(p, p + Vector3(0.657, 0, -0.657));

		gui.isViewer = true;
	}

	bool initialize(uint fov, string backend)
	{
		auto t = TimeMeter(`main window creation`);

		void onResize(Vector2s sz)
		{
			PE.scene.proj = Matrix4.makePerspective(float(sz.x) / sz.y, fov, 10, 1000);
		}

		PE.onResize.permanent(&onResize);

		try
		{
			PE.create(`Æsir`, backend ? backend : `vulkan`);
		}
		catch (Exception e)
		{
			debug
			{
				logger.msg(e);
			}
			else
				showErrorMessage("Your graphics driver seems to be outdated.\nUpdate it and try again.\n\nError message: " ~ e.msg);

			return false;
		}

		PE.timers.add(&onWork, 0, 0);
		ctors;

		PE.gui.drawGUI = &gui.draw;

		PE.hotkeys.add(Hotkey(null, { gui.showSettings ^= true; return true; }, SDLK_ESCAPE));

		return true;
	}

	void onWork()
	{
		_pmgr.process;
		_emgr.process;
	}

	mixin createCtorsDtors!(_rmgr, _db, gui, _emgr, _pmgr, action, status, items, effects);

	RoDb _db;
	PacketManager _pmgr;
	EntityManager _emgr;
	ResourcesManager _rmgr;
}

struct RoSettings
{
	string serv;
	string[] grfs;
}
