module rocl.paths;

import
		std.format;

enum
{
	GUI_PATH = `gui.rog`,
	FONT_FILE = `data/font/notosans-regular.ttf`,
}

auto koreanSex(bool male) { return male ? `남` : `여`; }

auto strSex(bool male) { return male ? `male` : `female`; }

auto mapPath(string s) { return format(`map/%s.rom`, s); }

auto jobPath(ushort id, bool gender) { return format(`sprite/job/%u_%s.asp`, id, gender.strSex); }

auto headPath(ushort id, bool gender, ubyte palette) { return format(`sprite/head/%u_%u_%s.asp`, id, palette, gender.strSex); }

auto actorPath(ushort id) { return format(`sprite/mob/%u.asp`, id); }

auto itemPath(string s) { return format(`item/%s.roi`, s); }

auto skillPath(string s) { return format(`skill/%s.roi`, s); }
