module rocl.controls.hotkeysettings;

import
		std.experimental.all,

		perfontain,

		rocl;


final:

class WinHotkeySettings : WinBasic2
{
	this()
	{
		super(MSG_HOTKEY_SETTINGS);

		auto e = new TextTabs(main, [ MSG_SKILLS ~ ` 1-2`, MSG_SKILLS ~ ` 3-4`, MSG_INTERFACE ]);

		foreach(i, u; e.tabs)
		{
			//new GUIStaticText(u, i.to!string);
			foreach(k; 0..10)
			{
				auto r = new HotkeySelector(u, `My super action`);

				r.pos.y = cast(short)(r.size.y * k + 4);
			}

		}

		e.adjust;

		main.toChildSize;
		main.pad(10);

		adjust;
		center;

		//PE.onKey.permanent((a, b) { SDL_GetKeyName(a).fromStringz.writeln; });
	}
}

class HotkeySelector : GUIElement
{
	this(GUIElement p, string n)
	{
		super(p);

		auto t = new GUIStaticText(this, n);

		{
			auto f = PE.fonts.base;
			auto w = 120;//f.widthOf(`SHIFT+CTRL+Z`);

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

			und.size = Vector2s(w + 8, f.height + 1);
			und.moveX(t, POS_ABOVE, 4);
		}

		toChildSize;
		makeText(`none`);
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
		}
	}

	void processKey(uint k, bool st)
	{
		if(st && k != SDLK_ESCAPE)
		{
			_keys ~= k;
			makeText(_keys.map!(a => nameOf(a)).join(`+`));
		}
		else
		{
			record(false);
		}
	}

	void makeText(string s)
	{
		und.childs.clear;

		auto e = new GUIStaticText(und, s);
		e.moveX(und, POS_CENTER);
	}

	static nameOf(uint k)
	{
		return cast(string)SDL_GetKeyName(k).fromStringz;
	}

	uint[] _keys;
	RC!ConnectionPoint _cp;
}
