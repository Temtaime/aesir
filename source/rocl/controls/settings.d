module rocl.controls.settings;

import
		std.meta,
		std.array,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		ro.conv.gui,

		rocl,
		rocl.rofs,
		rocl.game,
		rocl.controls;


final class WinSettings : WinBasic
{
	this(bool viewer = false)
	{
		name = `settings`;

		super(Vector2s(300, 250), MSG_SETTINGS);

		if(pos.x < 0)
		{
			center;
		}

		struct S
		{
			string
					caption,
					var;

			string[] values;

			string cond = `true`;
		}

		enum Arr =
		[
			S(`MSG_SHADOWS`, `PE.settings.shadows`, [ `MSG_NO`, `MSG_LOW`, `MSG_MIDDLE`, `MSG_HIGH`, `MSG_HIGHEST` ]),
			S(`MSG_LIGHTING`, `PE.settings.lights`, [ `MSG_NO`, `MSG_DIFFUSE`, `MSG_FULL` ]),
			S(`MSG_RENDER_QUALITY`, `PE.settings.useBindless`, [ `MSG_MIDDLE`, `MSG_HIGH` ], `GL_ARB_bindless_texture`),

			S(`MSG_FOG`, `PE.settings.fog`),

			S(`MSG_FULLSCREEN`, `PE.settings.fullscreen`),
			S(`MSG_ANTIALIASING`, `PE.settings.msaa`),
			S(`MSG_VSYNC`, `PE.settings.vsync`),
		];

		ushort w;
		auto sp = 22;

		foreach(i, c; aliasSeqOf!Arr)
		{
			auto e = new GUIStaticText(this, mixin(c.caption));
			e.pos = Vector2s(WPOS_START, (i + 1) * sp + (sp - e.size.y) / 2);

			w = max(w, e.size.x);
		}

		foreach(i, c; aliasSeqOf!Arr)
		{
			if(mixin(c.cond))
			{
				static if(c.values)
				{
					GUIElement[] arr;

					foreach(u; aliasSeqOf!(Arr[i].values))
					{
						arr ~= new GUIStaticText(null, mixin(u));
					}

					auto k = arr.map!(a => a.size.x).fold!max;
					auto e = new SelectBox(this, arr, SELECT_ARROW, SCROLL_ARROW, cast(ushort)(k + 25), mixin(c.var));
				}
				else
				{
					auto e = new CheckBox(this, CHECKBOX, CHECKBOX_SZ, mixin(c.var));
				}

				e.onChange = (a)
				{
					mixin(c.var ~ `= cast(typeof( ` ~ c.var ~ `))a;`);
				};

				e.pos = Vector2s(WPOS_START + w + 5, (i + 1) * sp + (sp - e.size.y + 1) / 2);
			}
		}

		if(viewer)
		{
			GUIElement[] arr;

			auto maps = (cast(RoFileSystem)PEfs).grfs
														.map!(a => a.files.byKey)
														.joiner
														.filter!(a => a.startsWith(`data/`) && a.endsWith(`.rsw`))
														.map!(a => a[5..$ - 4])
														.array
														.sort()
														.uniq
														.array;

			foreach(n; maps)
			{
				arr ~= new GUIStaticText(null, n);
			}

			auto k = arr.map!(a => a.size.x).fold!max;
			auto e = new SelectBox(this, arr, SELECT_ARROW, SCROLL_ARROW, cast(ushort)(k + 25), cast(short)maps.countUntil(`prontera`));

			e.onChange = (a)
			{
				try ROres.load(maps[a]); catch(Exception e) e.log;
			};

			e.pos = Vector2s(WPOS_START, size.y - WIN_BOTTOM_SZ.y - e.size.y - 2);
		}
		else
		{
			auto b = new Button(this, BTN_PART, MSG_HOTKEYS);

			b.move(this, POS_MAX, -5, this, POS_MAX, -3);
			b.onClick = &ROgui.createHotkeySettings;
		}
	}
}
