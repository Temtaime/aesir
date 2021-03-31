module rocl.controls.settings;

import std.meta, std.array, std.algorithm, perfontain, perfontain.opengl,

	ro.conv.gui, rocl, rocl.rofs, rocl.game, rocl.controls;

final class WinSettings //: GUIWindow
{
	this(bool viewer = false)
	{
		super(MSG_SETTINGS, Vector2s(340, 255));

		struct S
		{
			string caption, var;

			string[] values;

			string cond = `true`;
		}

		enum Arr = [
				S(`MSG_SHADOWS`, `PE.settings.shadows`, [
						`MSG_NO`, `MSG_LOW`, `MSG_MIDDLE`, `MSG_HIGH`,
						`MSG_HIGHEST`
						]),
				S(`MSG_LIGHTING`, `PE.settings.lights`, [
						`MSG_NO`, `MSG_DIFFUSE`, `MSG_FULL`
						]),
				S(`MSG_RENDER_QUALITY`, `PE.settings.useBindless`,
						[`MSG_MIDDLE`, `MSG_HIGH`], `GL_ARB_bindless_texture`),

				S(`MSG_FOG`, `PE.settings.fog`),

				S(`MSG_FULLSCREEN`, `PE.settings.fullscreen`),
				S(`MSG_ANTIALIASING`, `PE.settings.msaa`),
				S(`MSG_VSYNC`, `PE.settings.vsync`),
			];

		addLayout(new DynamicRowLayout(2));

		foreach (i, c; aliasSeqOf!Arr)
		{
			if (mixin(c.cond))
			{
				//t.add(new GUIStaticText(null, mixin(c.caption)));

				static if (c.values)
				{
					string[] arr;

					foreach (u; aliasSeqOf!(Arr[i].values))
					{
						arr ~= mixin(u);
					}

					new GUIStaticText(curLayout, mixin(c.caption));
					auto e = new TextCombo(curLayout, arr, mixin(c.var));
				}
				else
				{
					auto e = new CheckBox(curLayout, mixin(c.caption), mixin(c.var));
				}

				e.onChange = (a) {
					mixin(c.var ~ `= cast(typeof( ` ~ c.var ~ `))a;`);
					return true;
				};
			}
		}

		if (viewer)
		{
			GUIElement[] arr;

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

	/*override void poseDefault()
	{
		center;
	}*/
}
