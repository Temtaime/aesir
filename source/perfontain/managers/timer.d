module perfontain.managers.timer;

import
		std.stdio,
		std.array,
		std.algorithm,

		perfontain,
		perfontain.misc,
		perfontain.signals;


enum : ubyte
{
	TM_ONCE		= 1,
}

final class TimerManager
{
	auto add(void delegate() dg, uint tick, ubyte flags = TM_ONCE)
	{
		_timers ~= new Timer(tick, flags, PE.tick + tick, false, dg);
		return _timers.back;
	}

	void process()
	{
		for(uint i; i < _timers.length; )
		{
			auto t = _timers[i];

			with(t)
			{
				if(removed)
				{
					_timers = _timers.remove(i);
				}
				else
				{
					if(next <= PE.tick)
					{
						exec;
					}

					i++;
				}
			}
		}
	}

private:
	Timer *[] _timers;
}

struct Timer
{
	void exec()
	{
		assert(!removed);

		_dg();

		if(flags & TM_ONCE)
		{
			removed = true;
		}
		else
		{
			next = PE.tick + tick;
		}
	}

	const
	{
		uint tick;
		ubyte flags;
	}

	uint next;
	bool removed;
private:
	const void delegate() _dg;
}
