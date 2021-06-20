module rocl.resources;
import std.file, std.format, std.algorithm, perfontain, ro.map, ro.conv, ro.conf, ro.conv.gui, rocl.game, rocl.paths,
	rocl.loaders.map, rocl.loaders.asp;

final class ResourcesManager
{
	this()
	{
	}

	~this()
	{
		_sprites.byValue
			.filter!(a => !!a)
			.each!(a => a.release);
	}

	// ---------------------- ground related ----------------------
	const heightOf(Vector2 pos)
	{
		pos += 0.5;
		auto idx = makeIdx(clampVec(pos.Vector2s)) * 4;
		pos %= 1;

		with (_map)
		{
			auto x1 = heights[idx + 0] + (heights[idx + 1] - heights[idx + 0]) * pos.x,
				x2 = heights[idx + 2] + (heights[idx + 3] - heights[idx + 2]) * pos.x;

			return (x1 + (x2 - x1) * pos.y) / -ROM_SCALE_DIV + 0.1f;
		}
	}

	const flagsOf(Vector2s pos)
	{
		return _map.flags[makeIdx(clampVec(pos))];
	}

	const size()
	{
		return _map.size;
	}

	// ---------------------- loading related ----------------------
	auto load(in AspLoadInfo r)
	{
		auto s = r in _sprites;

		if (!s)
		{
			s = &(_sprites[r] = loadASP(r));

			if (*s)
			{
				s.acquire;
			}
		}

		return *s;
	}

	void load(string name)
	{
		auto t = TimeMeter(`loading map %s`, name);
		auto r = ROdb.mapName(name);

		with (PE.scene)
		{
			scene = null;
			scene = RomLoader(r).process(_map);
		}

		_mapName = name;
		RO.action.enable;
	}

private:
	mixin publicProperty!(string, `mapName`);

	const makeIdx(Vector2s p)
	{
		return p.y * _map.size.x + p.x;
	}

	const clampVec(Vector2s p)
	{
		p.x = clamp(p.x, short.init, _map.size.x);
		p.y = clamp(p.y, short.init, _map.size.y);

		return p;
	}

	RomGround _map;
	SpriteObject[AspLoadInfo] _sprites;
}
