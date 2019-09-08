module ro.db;

import
		std,

		perfontain,
		rocl,

		utils.db,
		utils.logger;


struct RoItemData
{
	string name, res;
}

final class RoDb
{
	this()
	{
		_db = new SQLite(`:memory:`);

		{
			auto data = PEfs.get(`data/ro.db`);
			auto p = buildPath(tempDir, `__perfontain_db`);

			data.toFile(p);

			{
				scope e = new SQLite(p);
				e.backup(_db);
			}

			remove(p);
		}
	}

	~this()
	{
		_db.destroy;
	}

	auto skill(string id)
	{
		return _db.queryOne!string(`select coalesce((select ` ~ lang ~ ` from skills where name = upper(?)), "???");`, id);
	}

	auto skill(uint id)
	{
		return _db.queryOne!string(`select coalesce((select ` ~ lang ~ ` from skills where id = ?), "???");`, id);
	}

	auto skilldesc(string id)
	{
		return _db.queryOne!string(`select coalesce((select desc_` ~ lang ~ ` from skills where name = upper(?)), "???");`, id);
	}

	auto itemOf(ushort id)
	{
		auto res = _db.query!(string, string)(`select ` ~ lang ~ `, res from items where id = ?;`, id);

		if(res.empty)
		{
			return new RoItemData(`???`, `사과`);
		}

		return new RoItemData(res.front.expand);
	}

	auto hatOf(ushort id)
	{
		return _db.queryOne!string(`select coalesce((select name from hats where id = ?), "고글");`, id);
	}

	auto actorOf(ushort id)
	{
		return _db.queryOne!string(`select coalesce((select name from actors where id = ?), "poring");`, id);
	}

	auto skillEffect(uint id)
	{
		return _db.query!uint(`select main from sk_effects join skills using(name) where id = ?;`, id).array;
	}

	auto effect(uint id)
	{
		return _db.query!(string, uint)(`select name, rnd from effects where id = ?;`, id).array;
	}

	auto packetLens()
	{
		return _db.query!(ushort, short)(`select id, len from packets;`).array.assocArray;
	}

	auto mapName(string n)
	{
		return _db.queryOne!string(`select coalesce((select value from map_names where id = e), e) from (select ? as e);`, n);
	}

	auto jobName(uint id)
	{
		return _db.queryOne!string(format(`select name from jobs where id = %u;`, id));
	}

private:
	SQLite _db;
}

private:

auto strFile(ushort id)
{
	//auto e = &strEffect[id];
	//return e.rnd ? format(e.file, 1 + uniform(0, e.rnd)) : e.file;
}
