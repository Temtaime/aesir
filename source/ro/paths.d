module ro.paths;
import std, std.digest, rocl, utile.misc, std.ascii : toLower;

struct RoPath
{
	this(A...)(A args)
	{
		foreach (s; args)
			this ~= s;
	}

	static normalized(A...)(A args)
	{
		return RoPath(args).data.map!(a => cast(ubyte)(a == '\\' ? '/' : a.toLower)).array.RoPath;
	}

	ref opOpAssign(string op : `~`)(in RoPath p)
	{
		data ~= p.data;
		return this;
	}

	ref opOpAssign(string op : `~`)(string s)
	{
		data ~= s.representation;
		return this;
	}

	ref opOpAssign(string op : `~`)(const(ubyte)[] s)
	{
		data ~= s;
		return this;
	}

	ref opOpAssign(string op : `~`, size_t N)(const(char)[N] s)
	{
		data ~= s.representation.until(0);
		return this;
	}

	ref opOpAssign(string op : `~`)(ubyte v)
	{
		data ~= v;
		return this;
	}

	bool opCast(T : bool)() const
	{
		return !!data;
	}

	string toString() const
	{
		return data.map!(a => a.isPrintable ? [cast(immutable char)a] : `\x` ~ a.toByte.toHexString).join;
	}

	immutable(ubyte)[] data;
}

struct RoPathMaker
{
static:
	auto water(ubyte type, ushort idx)
	{
		return RoPath("data/texture/\xBF\xF6\xC5\xCD/", format(`water%u%02u.jpg`, type, idx)); // 워터
	}

	auto itemIcon(string name)
	{
		return RoPath("data/texture/\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA/item/", name, `.bmp`); // 유저인터페이스
	}

	auto palette(string name)
	{
		enum X = "\xB8\xD3\xB8\xAE"; // 머리
		return RoPath(`data/palette/`, X, '/', X, name, `.pal`);
	}

	auto bodySprite(uint id, bool male)
	{
		auto name = ROdb.jobName(id);
		return RoPath("data/sprite/\xC0\xCE\xB0\xA3\xC1\xB7/\xB8\xF6\xC5\xEB/", sexPath(name, male)); // 인간족 / 몸통
	}

	auto mobSprite(ushort id)
	{
		return RoPath("data/sprite/\xB8\xF3\xBD\xBA\xC5\xCD/", ROdb.actorOf(id)); // 몬스터
	}

	auto npcSprite(ushort id)
	{
		return RoPath(`data/sprite/npc/`, ROdb.actorOf(id));
	}

	auto headSprite(ushort id, bool male)
	{
		auto name = id.to!string;
		return RoPath("data/sprite/\xC0\xCE\xB0\xA3\xC1\xB7/\xB8\xD3\xB8\xAE\xC5\xEB/", sexPath(name, male)); // 인간족 / 머리통
	}

	auto hatSprite(ushort id, bool male)
	{
		auto name = ROdb.hatOf(id);
		return RoPath("data/sprite/\xBE\xC7\xBC\xBC\xBB\xE7\xB8\xAE/", sexPath(name, male)); // 악세사리
	}

	auto sex(bool male)
	{
		return RoPath(male ? "\xB3\xB2" : "\xBF\xA9"); // 남 / 여
	}

	enum DEFAULT_ITEM = RoPath("\xBB\xE7\xB0\xFA"); // 사과 : apple
private:
	auto sexPath(string name, bool male)
	{
		auto sex = sex(male);
		return RoPath(sex, '/', name, '_', sex);
	}
}
