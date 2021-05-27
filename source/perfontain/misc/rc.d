module perfontain.misc.rc;
import std, std.experimental.allocator, std.experimental.allocator.mallocator, core.memory, utile.misc, utile.logger;

//version = LOG_RC;
alias Alloc = Mallocator.instance;

auto allocateRC(T, A...)(auto ref A args)
{
	auto m = Alloc.allocate(stateSize!T);
	GC.addRange(m.ptr, m.length);

	auto e = emplace!T(m, args);
	e.useAllocator = true;
	return e;

	//return new T(args);
}

class RCounted
{
	~this()
	{
		version (LOG_RC)
			logger.msg!`%s destroying`(this);

		debug
		{
			if (!_wasFreed)
				logger.error!`%s was never acquired`(this);
		}
	}

final:
	bool isRcAlive()
	{
		return !!_refs;
	}

	void acquire()
	{
		debug
		{
			assert(!_wasFreed);
		}

		_refs++;

		version (LOG_RC)
			logger.msg!`%s, %u refs`(this, _refs);

		debug
		{
			rcLeaks[cast(void*)this]++;
		}
	}

	void release()
	{
		assert(_refs);

		version (LOG_RC)
			logger.msg!`%s, %u refs`(this, _refs - 1);

		if (!--_refs)
		{
			debug
			{
				_wasFreed = true;
				rcLeaks.remove(cast(void*)this);
			}

			const b = useAllocator;
			auto sz = b ? typeid(this).initializer.length : 0;

			this.destroy;

			if (b)
			{
				auto p = (cast(void*)this)[0 .. sz];

				GC.removeRange(p.ptr);
				Alloc.deallocate(p);
			}
		}
		else
			debug rcLeaks[cast(void*)this]--;
	}

	bool useAllocator;
private:
	uint _refs;
	debug bool _wasFreed;
}

struct RC(T)
{
	this(T p)
	{
		if (p)
		{
			_rcElem = p;
			p.acquire;
		}
	}

	~this()
	{
		if (_rcElem)
			_rcElem.release;
	}

	this(this)
	{
		if (_rcElem)
			_rcElem.acquire;
	}

	T opAssign(T p)
	{
		assert(!p || _rcElem !is p);

		if (_rcElem)
			_rcElem.release;

		_rcElem = p;

		if (_rcElem)
			_rcElem.acquire;

		return p;
	}

	T _rcElem;
	alias _rcElem this;
}

struct RCArray(T)
{
	this(T[] u)
	{
		opAssign(u);
	}

	this(this)
	{
		auto u = _arr;
		_arr = null;

		opAssign(u);
	}

	~this()
	{
		clear;
	}

	void clear()
	{
		releaseAll;
		resize(0);
	}

	void popBack()
	{
		back.release;
		resize(length - 1);
	}

	void remove(T t)
	{
		auto idx = _arr.countUntil!(a => a is t);
		auto e = _arr[idx];

		_arr.remove(idx);
		resize(length - 1);

		e.release;
	}

	void opIndexAssign(T p, size_t idx)
	{
		auto e = _arr[idx];

		_arr[idx] = p;
		p.acquire;

		e.release;
	}

	void opOpAssign(string op : `~`)(T p)
	{
		resize(length + 1);

		p.acquire;
		_arr[$ - 1] = p;
	}

	void opOpAssign(string op : `~`)(T[] arr)
	{
		resize(length + arr.length);

		foreach (i, p; arr)
		{
			p.acquire;
			_arr[$ - arr.length + i] = p;
		}
	}

	void opAssign(T[] u)
	{
		releaseAll;
		resize(u.length);

		_arr[] = u[];
		acquireAll;
	}

	inout front()
	{
		return _arr[0];
	}

	inout back()
	{
		return _arr[$ - 1];
	}

	inout opIndex(size_t idx)
	{
		return _arr[idx];
	}

	inout opSlice()
	{
		return _arr;
	}

	inout opSlice(size_t start, size_t end)
	{
		return _arr[start .. end];
	}

	const length()
	{
		return cast(uint)_arr.length;
	}

	const opDollar()
	{
		return length;
	}

private:
	void resize(size_t len)
	{
		if (_arr.ptr)
			GC.removeRange(_arr.ptr);

		if (len)
		{
			void[] u = _arr;

			const b = Alloc.reallocate(u, len * size_t.sizeof);
			assert(b);

			GC.addRange(u.ptr, u.length);
			_arr = u.as!T;
		}
		else if (_arr.ptr)
		{
			Alloc.deallocate(_arr);
			_arr = null;
		}

		//_arr.length = len;
	}

	void acquireAll()
	{
		_arr.each!(a => a.acquire);
	}

	void releaseAll()
	{
		_arr.each!(a => a.release);
	}

	T[] _arr;
}

auto asRC(T)(T p)
{
	return RC!T(p);
}

debug
{
	void logLeaks()
	{
		debug
		{
			if (rcLeaks.length)
			{
				logger.error(`reference counting leaks:`);
				logger.ident++;

				foreach (k, v; rcLeaks)
				{
					logger.warning!`%s - %u refs`((cast(Object)k).toString, v);
				}

				logger.ident--;
			}
			else
				logger.info(`no reference counting leaks are found`);
		}
	}

	private uint[void* ] rcLeaks;
}
