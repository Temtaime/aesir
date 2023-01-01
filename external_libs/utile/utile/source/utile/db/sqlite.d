module utile.db.sqlite;
import std, core.sync.mutex, core.sync.rwmutex, etc.c.sqlite3, utile.except, utile.db, utile.misc;

final class SQLite
{
	this(string name)
	{
		const(char)* p;
		auto flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;

		if (name.empty)
		{
			flags |= SQLITE_OPEN_MEMORY;
		}
		else
			p = name.toStringz;

		sqlite3_open_v2(p, &_db, flags, null) == SQLITE_OK || error;

		query(`pragma foreign_keys = ON;`);
		query(`pragma temp_store = MEMORY;`);
		query(`pragma synchronous = NORMAL;`);
	}

	~this()
	{
		_cache.byValue.each!(a => remove(a));
		sqlite3_close(_db);
	}

	void backup(SQLite dest)
	{
		auto bk = sqlite3_backup_init(dest._db, MainDb, _db, MainDb);
		bk || throwError(`cannot init backup`);

		scope (exit)
		{
			sqlite3_backup_finish(bk);
		}

		sqlite3_backup_step(bk, -1) == SQLITE_DONE || error;
	}

	void begin() => cast(void)query(`begin;`);
	void end() => cast(void)query(`end;`);
	void rollback() => cast(void)query(`rollback;`);

	mixin DbBase;
private:
	enum immutable(char)[4] MainDb = `main`;

	void process(sqlite3_stmt* stmt)
	{
		execute(stmt);
		reset(stmt);
	}

	auto process(A...)(sqlite3_stmt* stmt)
	{
		auto self = this; // TODO: DMD BUG

		struct S
		{
			this(this) @disable;

			~this() => self.reset(stmt);

			const empty() => !_hasRow;

			void popFront()
			in
			{
				assert(_hasRow);
			}
			do
			{
				_hasRow = self.execute(stmt);
			}

			auto array()
			{
				ReturnType!front[] res;

				for (; _hasRow; popFront)
				{
					res ~= front;
				}

				return res;
			}

			auto front()
			in
			{
				assert(_hasRow);
			}
			do
			{
				Tuple!A r;

				debug
				{
					auto N = r.Types.length;
					auto cnt = sqlite3_column_count(stmt);

					cnt == N || throwError!`expected %u columns, but query returned %u`(N, cnt);
				}

				foreach (i, ref v; r)
				{
					alias T = r.Types[i];

					static if (isFloatingPoint!T)
					{
						v = cast(T)sqlite3_column_double(stmt, i);
					}
					else static if (isIntegral!T)
					{
						v = cast(T)sqlite3_column_int64(stmt, i);
					}
					else static if (is(T == string))
					{
						v = sqlite3_column_text(stmt, i)[0 .. dataLen(i)].idup;
					}
					else static if (is(T == Blob))
					{
						v = cast(Blob)sqlite3_column_blob(stmt, i)[0 .. dataLen(i)];
						v = v.dup;
					}
					else
						static assert(false);
				}

				static if (A.length > 1)
				{
					return r;
				}
				else
					return r[0];
			}

		private:
			auto dataLen(uint col) => sqlite3_column_bytes(stmt, col);

			bool _hasRow;
		}

		return S(execute(stmt));
	}

	auto prepare(string sql)
	{
		if (auto stmt = _cache.get(sql, null))
		{
			return stmt;
		}

		sqlite3_stmt* stmt;
		sqlite3_prepare_v2(_db, sql.toStringz, cast(uint)sql.length, &stmt, null) == SQLITE_OK || error(sql);

		return _cache[sql] = stmt;
	}

	void bind(A...)(sqlite3_stmt* stmt, A args)
	{
		debug
		{
			auto cnt = sqlite3_bind_parameter_count(stmt);
			A.length == cnt || throwError!`expected %u parameters to bind, but %u provided`(cnt, A.length);
		}

		foreach (uint i, v; args)
		{
			doBind(stmt, i + 1, v) == SQLITE_OK || error(stmt);
		}
	}

	auto lastId(sqlite3_stmt * ) => sqlite3_last_insert_rowid(_db);
	auto affected(sqlite3_stmt * ) => sqlite3_changes(_db);
private:
	uint doBind(T)(sqlite3_stmt* stmt, uint idx, const T v)
	{
		static if (is(T == U*, U) || is(T == typeof(null)))
		{
			if (v)
			{
				return doBind(stmt, idx, *v);
			}
			else
				return sqlite3_bind_null(stmt, idx);
		}
		else static if (isFloatingPoint!T)
		{
			return sqlite3_bind_double(stmt, idx, v);
		}
		else static if (isIntegral!T)
		{
			return sqlite3_bind_int64(stmt, idx, v);
		}
		else static if (is(T == string))
		{
			char z;
			return sqlite3_bind_text(stmt, idx, v.ptr ? v.ptr : &z, cast(uint)v.length, SQLITE_TRANSIENT);
		}
		else static if (is(T == Blob))
		{
			ubyte z;
			return sqlite3_bind_blob64(stmt, idx, v.ptr ? v.ptr : &z, v.length, SQLITE_TRANSIENT);
		}
		else
			static assert(false, `unsupported bind type`);
	}

	void reset(sqlite3_stmt* stmt)
	{
		sqlite3_reset(stmt);
	}

	void remove(sqlite3_stmt* stmt)
	{
		sqlite3_finalize(stmt);
	}

	bool execute(sqlite3_stmt* stmt)
	{
		auto res = sqlite3_step(stmt);
		res == SQLITE_ROW || res == SQLITE_DONE || error(stmt);
		return res == SQLITE_ROW;
	}

	noreturn error(sqlite3_stmt * stmt) => error(sqlite3_sql(stmt).fromStringz.idup);

	noreturn error(string sql = null)
	{
		if (sql)
			sql ~= ` - `;
		sql ~= sqlite3_errmsg(_db).fromStringz.idup;

		return throwError(sql);
	}

	sqlite3* _db;
	sqlite3_stmt*[string] _cache;
}
