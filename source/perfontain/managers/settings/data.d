module perfontain.managers.settings.data;

import
		std.meta,
		std.string,
		std.traits,

		perfontain;


enum : ubyte
{
	SHADOWS_NONE,
	SHADOWS_LOW,
	SHADOWS_MEDIUM,
	SHADOWS_HIGH,
	SHADOWS_ULTRA,
}

enum : ubyte
{
	LIGHTS_OFF,
	LIGHTS_GLOBAL,
	LIGHTS_FULL,
}

struct WindowData
{
	Vector2s pos;
}

struct Settings
{
	WindowData[string] wins;
	SDL_Keycode[][string] hotkeys;

	ubyte
			lights = LIGHTS_GLOBAL,
			shadows = SHADOWS_MEDIUM;

	bool

			fog = true,
			vsync = true,
			msaa,
			fullscreen,
			useBindless;
}

package:

auto genSettings()
{
	string s;

	foreach(n; __traits(allMembers, Settings))
	{
		alias T = typeof(__traits(getMember, Settings, n));

		static if(isAssociativeArray!T)
		{
			s ~= `ref ` ~ n ~ `() { return _st.` ~ n ~ `; }`;
		}
		else
		{
			s ~= `@property ` ~ n ~ `() { return _st.` ~ n ~ `; }`;
			s ~= `@property ` ~ n ~ `(` ~ T.stringof ~ ` v) { _st.` ~ n ~ `= v;` ~ n ~ `Change(v); }`;
		}

		s ~= `perfontain.Signal!(void,` ~ T.stringof ~ `) ` ~ n ~ `Change;`;
	}

	return s;
}
