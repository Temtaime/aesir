module rocl.controls.settings;
import std.meta, std.array, std.algorithm, perfontain, perfontain.opengl, ro.conv.gui, rocl, rocl.rofs, rocl.game,
	rocl.controls, ro.paths;

struct WinSettings
{
	void draw(bool viewer)
	{
		auto sz = Vector2s(340, 255);
		auto pos = (PE.window.size - sz) / 2;

		if (auto win = Window(nk, MSG_SETTINGS, nk_rect(pos.x, pos.y, sz.x, sz.y)))
		{
			process(viewer);
		}
	}

private:
	mixin Nuklear;

	void process(bool viewer)
	{
		struct S
		{
			string caption, var;
			string[] values;
			string cond = `true`;
		}

		enum Arr = [
				S(`MSG_SHADOWS`, `PE.settings.shadows`, [`MSG_NO`, `MSG_LOW`, `MSG_MIDDLE`, `MSG_HIGH`,
						`MSG_HIGHEST`]), S(`MSG_LIGHTING`, `PE.settings.lights`, [`MSG_NO`, `MSG_DIFFUSE`, `MSG_FULL`]),
				S(`MSG_FOG`, `PE.settings.fog`), S(`MSG_FULLSCREEN`, `PE.settings.fullscreen`),
				S(`MSG_ANTIALIASING`, `PE.settings.msaa`), S(`MSG_VSYNC`, `PE.settings.vsync`),
			];

		bool single;
		nk.layout_row_dynamic(0, 2);

		foreach (i, c; aliasSeqOf!Arr)
		{
			if (mixin(c.cond))
			{
				static if (c.values)
				{
					string[] arr;

					foreach (u; aliasSeqOf!(Arr[i].values))
					{
						arr ~= mixin(u);
					}

					auto v = mixin(c.var);
					auto label = arr[v];

					nk.label(mixin(c.caption));

					if (auto combo = Combo(nk, label))
					{
						nk.layout_row_dynamic(combo.height, 1);

						foreach (k, s; arr)
						{
							if (combo.item(s))
							{
								mixin(c.var) = cast(typeof(v))k;
							}
						}
					}
				}
				else
				{
					if (!single)
					{
						single = true;
						nk.layout_row_dynamic(0, 1);
					}

					bool v = mixin(c.var);

					if (nk.checkbox(mixin(c.caption), v))
					{
						mixin(c.var) = !v;
					}
				}
			}
		}

		if (viewer)
		{
			if (!_maps)
			{
				auto ro = cast(RoFileSystem)PEfs;

				_maps = ro.grfs
					.map!(a => a.files.byKey)
					.joiner
					.filter!(a => a.data.startsWith(`data/`) && a.data.endsWith(`.rsw`))
					.map!(a => a.data[5 .. $ - 4])
					.array
					.sort
					.uniq
					.map!(a => RoPath(a).toString)
					.array;
			}

			if (auto combo = Combo(nk, ROres.mapName))
			{
				nk.layout_row_dynamic(combo.height, 1);

				foreach (m; _maps)
				{
					if (combo.item(m))
					{
						try
						{
							ROres.load(m);
						}
						catch (Exception e)
						{
							logger.error(e);
						}
					}
				}
			}

			//GUIElement[] arr;

			// auto maps = (cast(RoFileSystem)PEfs).grfs
			// 	.map!(a => a.files.byKey)
			// 	.joiner
			// 	.filter!(a => a.startsWith(`data/`) && a.endsWith(`.rsw`))
			// 	.map!(a => a[5 .. $ - 4])
			// 	.array
			// 	.sort().uniq.array;

			//if (maps.length) // TODO: FIX
			{
				/*auto e = new TextCombo(curLayout, maps, cast(short) maps.countUntil(`prontera`));

				e.onChange = (a) {
					try
					{
						ROres.load(maps[a]);
					}
					catch (Exception e)
					{
						e.logger;
					}

					return true;
				};*/
			}
		}
		else
		{
			//auto e = new Button(this, MSG_HOTKEYS, () => RO.gui.createHotkeySettings); // TODO: DELEGATE
			//e.move(POS_MIN, 4, POS_CENTER);
		}
	}

private:
	string[] _maps;
}
