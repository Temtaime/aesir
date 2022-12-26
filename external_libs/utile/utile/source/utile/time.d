module utile.time;
import core.time, utile;

uint systemTick()
{
	return cast(uint)TickDuration.currSystemTick.msecs;
}

struct TimeMeter
{
	this(A...)(string msg, in A args)
	{
		static if (args.length)
		{
			msg = format(msg, args);
		}

		_msg = msg;
		_tick = systemTick;
	}

	~this()
	{
		logger.msg!`%s : %u ms`(_msg, systemTick - _tick);
	}

private:
	string _msg;
	uint _tick;
}
