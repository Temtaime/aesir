module utile.db;
import std, utile.except;

public import utile.db.mysql, utile.db.sqlite;

alias Blob = const(ubyte)[];

unittest
{
	{
		scope db = new SQLite(null);

		{
			Blob arr = [1, 2, 3];

			auto res = db.queryOne!Blob(`select ?;`, arr);

			assert(res == arr);
		}

		{
			auto res = db.query!(uint, string)(`select ?, ?;`, 123, `hello`).array;

			assert(res.equal(tuple(123, `hello`).only));
		}

		assert(db.queryOne!uint(`select ? is null;`, string.init) == 0);
		assert(db.queryOne!uint(`select ? is null;`, cast(string*)null) == 1);

		{
			string s = `hello`;

			assert(db.queryOne!string(`select ?;`, s) == s);
			assert(db.queryOne!string(`select ?;`, &s) == s);
		}
	}

	version (Utile_Mysql)
	{
		MySQL db;

		auto res = db.query!(uint, string)(`select ?, ?;`, 123, `hello`);
		auto res2 = db.queryOne!uint(`select ?;`, 123);
	}
}

package:

mixin template DbBase()
{
	template query(T...)
	{
		auto query(A...)(string sql, A args)
		{
			auto stmt = prepare(sql);
			bind(stmt, args);

			static if (T.length)
			{
				return process!T(stmt);
			}
			else
			{
				process(stmt);
				auto self = this;

				struct S
				{
					auto id() => self.lastId(stmt);
					auto affected() => self.affected(stmt);
				}

				return S();
			}
		}
	}

	template queryOne(T...)
	{
		auto queryOne(A...)(string sql, A args)
		{
			auto res = query!T(sql, args);
			res.empty && throwError(`query returned no rows`);

			auto e = res.front;

			res.popFront;
			res.empty || throwError(`query returned multiple rows`);

			return e;
		}
	}
}
