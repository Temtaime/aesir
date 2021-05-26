module perfontain;
import std.utf, std.file, std.path, std.conv, std.array, std.range, std.stdio, std.traits, std.string, std.encoding,
	std.exception, std.algorithm : filter, map;

import core.time, core.thread, core.memory, perfontain.misc, perfontain.managers.state, perfontain.opengl,
	perfontain.sampler, perfontain.filesystem, perfontain.managers.audio, perfontain.math.frustum,
	perfontain.managers.shadow, perfontain.managers.sampler;

public import perfontain.misc, perfontain.misc.rc, perfontain.misc.dxt, perfontain.meshholder,
	perfontain.meshholder.structs, perfontain.meshholder.creator, perfontain.nodes, perfontain.nodes.octree,
	perfontain.nodes.sprite, perfontain.managers.gui, perfontain.managers.font, perfontain.managers.timer,
	perfontain.managers.scene, perfontain.managers.render, perfontain.managers.window, perfontain.managers.shadow,
	perfontain.managers.hotkey, perfontain.managers.objects, perfontain.managers.texture, perfontain.managers.settings,
	perfontain.shader, perfontain.shader.lang, perfontain.math.bbox, perfontain.math.matrix, perfontain.vao,
	perfontain.vbo, perfontain.mesh, perfontain.render, perfontain.camera, perfontain.config, perfontain.signals,
	perfontain.submesh, perfontain.program, perfontain.sampler, perfontain.filesystem, perfontain.rendertarget,
	stb.image, utile.except, utile.logger;

alias PE = Engine.instance;

@property ref PEfs()
{
	return PE.fs;
}

@property PEaudio()
{
	return PE.audio;
}

@property PEstate()
{
	return PE._state;
}

@property PEobjs()
{
	return PE._objs;
}

@property PEscene()
{
	return PE.scene;
}

@property PEwindow()
{
	return PE.window;
}

@property PEsamplers()
{
	return PE._samplers;
}

@property PEsettings()
{
	return PE.settings;
}

final class Engine
{
	__gshared instance = new Engine;

	void doInit()
	{
		if (!fs)
		{
			fs = new FileSystem;
		}

		if (!settings)
		{
			settings = new SettingsManager;
		}
	}

	~this()
	{
		// if (gui)
		// {
		// 	gui.root = null;
		// }

		dtors;

		debug
		{
			logLeaks;
		}
	}

	void create(string title, string backend)
	{
		_title = title;
		_backend = backend;
		_tick = systemTick;

		window = new WindowManager;
		window.create(makeTitle, _backend);

		logger.info2(`[gpu info]`);
		logger.info3!`opengl vendor: %s`(glGetString(GL_VENDOR).fromStringz);
		logger.info3!`opengl version: %s`(glGetString(GL_VERSION).fromStringz);
		logger.info3!`opengl renderer: %s`(glGetString(GL_RENDERER).fromStringz);
		logger.info3!`opengl sl version: %s`(glGetString(GL_SHADING_LANGUAGE_VERSION).fromStringz);

		{
			int v;
			glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &v);

			_aaLevel = v > 1 ? cast(ubyte)v : 0;

			if (_aaLevel)
			{
				logger.info!`anisotropy level = %ux`(_aaLevel);
			}
			else
			{
				logger.error(`anisotropic filtering is not supported`);
			}
		}

		if (_msaaLevel)
		{
			logger.info!`msaa level = %ux`(_msaaLevel);
		}
		else
		{
			logger.error(`msaa is not supported`);
		}

		_run = true;

		ctors;
		onResize(PE.window.size);

		{

			/*auto s = `hello WORLD`;

			auto f = PE.gui.ctx.style.font;
			auto w = f.width(cast()f.userdata, f.height, s.ptr, cast(int)s.length);

			logger(`%s %s`, w, f.height);*/

			//auto e = new InvisibleWindow(Vector2s(0));
			//new GUIStaticText(e, s);
		}
	}

	void work()
	{
		while (processWork)
		{
			glEnable(GL_DEPTH_TEST);

			//shadows.process;
			scene.draw;

			glDisable(GL_DEPTH_TEST);
			gui.draw;

			PEwindow.swapBuffers;
		}
	}

	void quit()
	{
		_run = false;
	}

	GUIManager gui;
	FontManager fonts;
	SceneManager scene;
	AudioManager audio;
	TimerManager timers;
	RenderManager render;
	WindowManager window;
	HotkeyManager hotkeys;
	ShadowManager shadows;
	TextureManager textures;
	SettingsManager settings;

	FileSystem fs;

	Signal!(void, Vector2s) onMove;
	Signal!(void, Vector2s) onMoveDelta;

	Signal!(void, uint) onTickDelta;
	Signal!(void, Vector2s) onResize;

	Signal!(bool, Vector2s) onWheel;
	Signal!(bool, ubyte) onDoubleClick;
	Signal!(bool, ubyte, bool) onButton;

	Signal!(bool, SDL_Keycode, bool) onKey;
package:
	mixin createCtorsDtors!(fs, settings, window, render, shadows, _samplers, _state, audio, timers, textures, scene,
			fonts, _objs, gui, hotkeys);

	mixin publicProperty!(bool, `run`);

	mixin publicProperty!(uint, `tick`);
	mixin publicProperty!(uint, `fpsCount`);

	bool processWork()
	{
		{
			auto t = systemTick;

			_diff = t - _tick;
			_tick = t;
		}

		if (_diff)
		{
			onTickDelta(_diff);
		}

		window.processEvents;

		{
			_fpsCounter++;
			auto delta = _tick - _fpsTick;

			if (delta >= FPS_UPDATE_TIME)
			{
				_fpsCount = _fpsCounter * 1000 / delta;

				_fpsCounter = 0;
				_fpsTick = _tick;

				window.title = makeTitle;

				//debug
				{
					showDebug;
				}
			}
		}

		timers.process;
		return _run;
	}

	void showDebug()
	{
		/*if(_debugInfo)
		{
			_debugInfo.childs.clear;
		}
		else
		{
			_debugInfo = new GUIQuad(PE.gui.root, colorWhite);
		}

		string s;

		s ~= format("fps: %u, %.1f ms\n", _fpsCount, _fpsCount ? 1000f / _fpsCount : 0);
		s ~= format("gui draws: %u, %u tris\n", render.drawAlloc[RENDER_GUI].drawnNodes, render.drawAlloc[RENDER_GUI].drawnTriangles);
		s ~= format("scene draws: %u, %u tris\n", render.drawAlloc[RENDER_SCENE].drawnNodes, render.drawAlloc[RENDER_SCENE].drawnTriangles);

		s.writeln;

		foreach(i, e; fonts.base.toLines(s.strip, 360))
		{
			auto t = new GUIStaticText(_debugInfo, e);
			t.pos = Vector2s(4, i * fonts.base.height);
		}

		_debugInfo.toChildSize;
		_debugInfo.size.x += 4;

		_debugInfo.pos = Vector2s(window.size.x - _debugInfo.size.x - 20, 20);*/
	}

	string makeTitle()
	{
		return format(`%s [ %s renderer, %u FPS ]`, _title, _backend, _fpsCount);
	}

	//GUIQuad _debugInfo;
	string _title, _backend;

	StateManager _state;
	ObjectsManager _objs;
	SamplerManager _samplers;

	uint _diff, _fpsTick, _fpsCount;

	ushort _fpsCounter;

	byte _aaLevel, _msaaLevel;
}
