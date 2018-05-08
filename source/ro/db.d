module ro.db;

import
		std.experimental.all,

		etc.c.sqlite3,

		perfontain,

		rocl,

		tt.error,
		tt.logger : log;


struct RoItemData
{
	string name, res;
}

final class RoDb
{
	this()
	{
		string p;

		debug
		{
			p = `data/ro.db`;
		}
		else
		{
			p = tempDir ~ `/pfstempdb`;
		}

		!sqlite3_open(p.toStringz, &_db) || throwError(sqlite3_errmsg(_db).fromStringz.assumeUnique);
	}

	~this()
	{
		sqlite3_close(_db);
	}

	auto skill(string id)
	{
		auto res = query!string(format(`select %s from skills where name = upper(%s);`, lang, escape(id)));
		return res.length ? res.front[0] : `???`;
	}

	auto skill(uint id)
	{
		auto res = query!string(format(`select %s from skills where id = %s;`, lang, id));
		return res.length ? res.front[0] : `???`;
	}

	auto skilldesc(string id)
	{
		auto res = query!string(format(`select desc_%s from skills where name = upper(%s);`, lang, escape(id)));
		return res.length ? res.front[0] : `???`;
	}

	auto itemOf(ushort id)
	{
		if(auto p = id in _items)
		{
			return *p;
		}

		auto res = query!(string, string)(format(`select %s, res from items where id = %u;`, lang, id));

		if(res.length)
		{
			auto d = new RoItemData(res.front.expand);
			return _items[id] = d;
		}

		return itemOf(512);
	}

	auto hatOf(ushort id)
	{
		auto res = query!string(format(`select name from hats where id = %u;`, id));

		return res.length ? res.front[0] : `고글`;
	}

	auto actorOf(ushort id)
	{
		auto res = query!string(format(`select name from actors where id = %u;`, id));

		//res.length || throwError(`unknown actor %u`, id);
		return res.length ? res.front[0] : `poring`;
	}

	auto hair(ushort id, bool male)
	{
		auto r = query!ushort(format(`select %smale from hairs where id = %u;`, male ? null : `fe`, id));

		if(r.length)
		{
			return r.front[0];
		}
		else
		{
			id != 1 || throwError(`can't find default hair`);

			log.error(`bad hair id = %u`, id);
			return hair(1, male);
		}
	}

//private:
	static escape(string s)
	{
		return format(`'%s'`, s.replace(`'`, `''`));//format(`%(%s%)`, s.sliceOne);
	}

	auto query(A...)(string q)
	{
		static if(A.length)
		{
			alias E = Tuple!A;
			auto res = appender!(E[]); // TODO: PRECISE GC FIX

			extern(C) int func(void *data, int n, char **fields, char **cols)
			{
				E e;

				foreach(k, T; A)
				{
					e[k] = fields[k].fromStringz.to!T; // TODO: check if « to » always calls to idup for strings
				}

				(cast(typeof(res) *)data).put(e);
				return 0;
			}

			auto cb = &func;
			auto data = &res;
		}
		else
		{
			enum cb = null;
			enum data = null;
		}

		sqlite3_exec(_db, q.toStringz, cb, data, null) == SQLITE_OK || throwError(`can't execute query: %s`, q);

		static if(A.length)
		{
			return res.data;
		}
	}

	sqlite3 *_db;
	RoItemData *[ushort] _items;
}

private:

auto strFile(ushort id)
{
	//auto e = &strEffect[id];
	//return e.rnd ? format(e.file, 1 + uniform(0, e.rnd)) : e.file;
}
