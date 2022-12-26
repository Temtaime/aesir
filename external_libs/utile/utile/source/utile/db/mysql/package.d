module utile.db.mysql;
import std.conv, std.meta, std.array, std.string, std.traits, std.typecons,
	std.exception, std.algorithm, utile.except, utile.db, utile.db.mysql.binding;

version (Utile_Mysql):

final class MySQL
{
	this(string host, string user, string pass, string db, uint port = 3306)
	{
		_db = mysql_init(null);

		{
			bool opt = true;
			!mysql_options(_db, MYSQL_OPT_RECONNECT, &opt) || throwError(lastError);
		}

		mysql_real_connect(_db, host.toStringz, user.toStringz, pass.toStringz,
				db.toStringz, port, null, 0) || throwError(lastError);
	}

	~this()
	{
		_stmts.byValue.each!(a => remove(a));
		mysql_close(_db);
	}

	mixin DbBase;
private:
	void process(MYSQL_STMT* stmt)
	{
		mysql_stmt_reset(stmt);
	}

	auto process(A...)(MYSQL_STMT* stmt)
	{
		assert(mysql_stmt_field_count(stmt) == A.length, `incorrect number of fields to return`);

		{
			bool attr = true;
			!mysql_stmt_attr_set(stmt, STMT_ATTR_UPDATE_MAX_LENGTH, &attr)
				|| throwError(lastError(stmt));
		}

		auto self = this; // TODO: DMD BUG

		struct S
		{
			this(this) @disable;

			~this()
			{
				mysql_stmt_free_result(stmt);
				mysql_stmt_reset(stmt);
			}

			bool empty() const
			{
				return !_hasRow;
			}

			void popFront()
			{
				assert(_hasRow);
				_hasRow = self.fetch(stmt);
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
			{
				assert(_hasRow);

				auto r = *_res;

				foreach (i, T; A)
				{
					static if (isSomeString!T)
					{
						r[i] = r[i][0 .. *_lens[i]].idup;
					}
				}

				static if (A.length > 1)
				{
					return r;
				}
				else
				{
					return r[0];
				}
			}

		private:
			void initialize()
			{
				MYSQL_BIND[] arr;
				_res = new Tuple!A;

				enforce(!mysql_stmt_store_result(stmt));

				{
					auto info = mysql_stmt_result_metadata(stmt);

					foreach (i, ref v; *_res)
					{
						c_ulong* len;

						static if (isSomeString!(A[i]))
						{
							_lens[i] = len = new c_ulong;
							v.length = info.fields[i].max_length;
						}

						arr ~= self.makeBind(&v, len);
					}

					mysql_free_result(info);
				}

				!mysql_stmt_bind_result(stmt, arr.ptr) || throwError(self.lastError(stmt));
				_hasRow = self.fetch(stmt);
			}

			Tuple!A* _res;
			c_ulong*[uint] _lens;
			bool _hasRow;
		}

		S s;
		s.initialize;
		return s;
	}

	auto prepare(string sql)
	{
		auto stmt = _stmts.get(sql, null);

		if (!stmt)
		{
			stmt = mysql_stmt_init(_db);
			!mysql_stmt_prepare(stmt, sql.ptr, cast(uint)sql.length) || throwError(lastError(stmt));

			_stmts[sql] = stmt;
		}

		return stmt;
	}

	void bind(A...)(MYSQL_STMT* stmt, A args)
	{
		MYSQL_BIND[] ps;
		assert(mysql_stmt_param_count(stmt) == A.length, `incorrect number of bind parameters`);

		foreach (ref v; args)
		{
			ps ~= makeBind(&v);
		}

		!mysql_stmt_bind_param(stmt, ps.ptr) || throwError(lastError(stmt));
		execute(stmt);
	}

	auto lastId(MYSQL_STMT* stmt)
	{
		return mysql_stmt_insert_id(stmt);
	}

	auto affected(MYSQL_STMT* stmt)
	{
		return mysql_stmt_affected_rows(stmt);
	}

	auto makeBind(T)(T* v, c_ulong* len = null)
	{
		MYSQL_BIND b;

		static if (is(T == typeof(null)))
		{
			b.buffer_type = MYSQL_TYPE_NULL;
		}
		else static if (isFloatingPoint!T)
		{
			b.buffer = v;
			b.buffer_type = T.sizeof == 4 ? MYSQL_TYPE_FLOAT : MYSQL_TYPE_DOUBLE;
		}
		else static if (isIntegral!T)
		{
			/*static*/
			immutable aa = [
				1 : MYSQL_TYPE_TINY, 2 : MYSQL_TYPE_SHORT, 4 : MYSQL_TYPE_LONG,
				8 : MYSQL_TYPE_LONGLONG,
			];

			b.is_unsigned = isUnsigned!T;
			b.buffer = v;
			b.buffer_type = aa[T.sizeof];
		}
		else static if (isSomeString!T)
		{
			b.length = len;
			b.buffer = cast(void*)v.ptr;
			b.buffer_length = cast(uint)v.length;
			b.buffer_type = MYSQL_TYPE_STRING;
		}
		else
		{
			static assert(false);
		}

		return b;
	}

	bool fetch(MYSQL_STMT* stmt)
	{
		auto r = mysql_stmt_fetch(stmt);

		r != MYSQL_DATA_TRUNCATED || throwError(`data was truncated`);
		r == MYSQL_NO_DATA || !r || throwError(lastError(stmt));

		return !r;
	}

	void remove(MYSQL_STMT* stmt)
	{
		mysql_stmt_close(stmt);
	}

	void execute(MYSQL_STMT* stmt)
	{
		!mysql_stmt_execute(stmt) || throwError(lastError(stmt));
	}

	auto lastError()
	{
		return mysql_error(_db).fromStringz;
	}

	auto lastError(MYSQL_STMT* stmt)
	{
		return mysql_stmt_error(stmt).fromStringz;
	}

	MYSQL* _db;
	MYSQL_STMT*[string] _stmts;
}
