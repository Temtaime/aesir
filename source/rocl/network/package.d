module rocl.network;

import
		std.path,
		std.conv,
		std.array,
		std.ascii,
		std.range,
		std.stdio,
		std.traits,
		std.string,
		std.socket,
		std.encoding,
		std.typetuple,
		std.algorithm,

		core.bitop,

		perfontain,
		perfontain.misc,

		ro.grf,
		ro.conf,

		rocl,
		rocl.game,
		rocl.status,
		rocl.entity,
		rocl.entity.actor,

		rocl.network.connection,
		rocl.network.packethandlers;

public import
				rocl.network.packets,
				rocl.network.structs;


//version = LOG_PACKETS;

final class PacketManager
{
	this()
	{
		_lengths = ROdb.packetLens;
		_lengths.rehash;

		initialize;
	}

	void login(string user, string pass)
	{
		{
			auto r = RO.settings.serv.findSplit(`:`);

			connect(getAddress(r[0], r[2].to!ushort).front);
		}

		send!Pk0064(26, user, pass, CLIENT_TYPE);
	}

	void process()
	{
		if(_reader.alive)
		{
			if(_flags & M_PING && PE.tick - _tick >= 30_000)
			{
				_tick = PE.tick;

				version(AE_ENCRYPTED_NET)
				{
					_tick &= ~1;
				}

				send!Pk0360(_tick);
			}

			for(_reader.process; processPacket; ) {}
		}
	}

	mixin PacketHandlers;
private:
	static pId(T)()
	{
		return T.stringof[2..$].to!ushort(16);
	}

	auto processPacket()
	{
		if(_flags & M_ACC_ID)
		{
			if(_reader.read(4))
			{
				_flags &= ~M_ACC_ID;
			}
			else
			{
				return false;
			}
		}

		version(AE_ENCRYPTED_NET)
		{
			if(_flags & M_ENC_KEY)
			{
				if(auto data = _reader.read(4))
				{
					_flags &= ~M_ENC_KEY;
					_reader.key = ~(*cast(uint *)data.ptr);
				}
				else
				{
					return false;
				}
			}
		}

		if(!parsePacket || !parseLen)
		{
			return false;
		}

		if(auto data = _reader.read(_plen))
		{
			auto func = _handlers.get(_pid, null);

			if(func)
			{
				func(data);
			}
			else
			{
				version(LOG_PACKETS)
				{
					logger.info3(`unknown packet 0x%X, %u bytes:`, _pid, _plen);

					dumpPacket(data);
					writeln;
				}
			}

			_pid = 0;
			return true;
		}

		return false;
	}

	void connect(Address addr)
	{
		disconnect;

		logger.info2(`connecting to %s...`, addr);
		_reader.connect(addr);

		_pid = 0;
		_tick = 0;
		_flags = 0;
	}

	void disconnect()
	{
		if(_reader.alive)
		{
			logger.info2(`disconnected`);
			_reader.close;
		}
	}

	void send(T, A...)(auto ref A args)
	{
		static if(T.tupleof.length)
		{
			T p;

			foreach(i, ref v; p.tupleof)
			{
				auto n = args[i];
				alias U = typeof(v);

				static if(is(typeof(n) : string))
				{
					static if(isStaticArray!U)
					{
						v[0..min($, n.length)] = n.toByte;
					}
					else
					{
						v = n.toByte;
					}
				}
				else
				{
					v = cast(U)n;
				}
			}

			auto data = p.binaryWrite;
		}
		else
		{
			ubyte[] data;
		}

		auto id = pId!T;
		checkId(id);

		version(LOG_PACKETS)
		{
			string name;

			static if(is(typeof(T.PK_NAME)))
			{
				name = format(`(%s)`, T.PK_NAME);
			}

			logger.info(`sending packet 0x%X%s, %u bytes:`, id, name, data.length);

			static if(is(typeof(p)))
			{
				logger(p);
			}
			else
			{
				logger("(no data)\n");
			}

			writeln;
		}

		_reader.write(id.toByte, false);

		{
			auto len = _lengths[id];

			if(len < 0)
			{
				len = cast(ushort)(data.length + 4);
				_reader.write(len.toByte, false);
			}
			else
			{
				//data.length == len - 2 || throwError!`trying to send packet 0x%X(real length %u) with wrong length(%u)`(id, len - 2, data.length);
			}
		}

		_reader.write(data);
	}

	void doPacket(alias F, T)(ubyte[] data)
	{
		try
		{
			auto p = data.binaryRead!T;

			version(LOG_PACKETS)
			{
				string name;

				static if(is(typeof(T.PK_NAME)))
				{
					name = format(`(%s)`, T.PK_NAME);
				}

				logger.info2(`packet 0x%X%s, %u bytes:`, _pid, name, _plen);
				logger("%s\n", p);
			}

			F(p);
		}
		catch(Exception e)
		{
			version(LOG_PACKETS)
			{
				string name;

				static if(is(typeof(T.PK_NAME)))
				{
					name = format(`(%s)`, T.PK_NAME);
				}

				logger.warning(`failed packet 0x%X%s, %u bytes:`, _pid, name, _plen);
				dumpPacket(data);
			}

			throw e;
		}
	}

	void checkId(ushort id)
	{
		debug
		{
			id in _lengths || throwError!`packet 0x%X is not presented in lengths table`(id);
		}
	}

	void dumpPacket(const(ubyte)[] data)
	{
		enum N = 24;

		if(data.length)
		{
			auto e = data.chunks(N);

			while(!e.empty)
			{
				auto c = e.front;
				e.popFront;

				logger(`%(%02X %)%*s %s%s`,
											c,
											(N - cast(int)c.length) * 3, ``,
											c.map!(b => b.isPrintable ? char(b) : '.'),
											e.empty ? "\n" : null);
			}
		}
		else
		{
			logger("(no data)\n");
		}
	}

	bool parsePacket()
	{
		if(!_pid)
		{
			if(auto data = _reader.read(2, false))
			{
				_pid = *cast(ushort *)data.ptr;
				_plen = _lengths.get(_pid, 0);

				_plen || throwError!`unknown packet 0x%X`(_pid);
				_plen -= 2;
			}
			else
			{
				return false;
			}
		}

		return true;
	}

	bool parseLen()
	{
		if(_plen < 0)
		{
			if(auto data = _reader.read(2, false))
			{
				_plen = *cast(ushort *)data.ptr;
				_plen -= 4;
			}
			else
			{
				return false;
			}
		}

		return true;
	}

	enum
	{
		M_ACC_ID		= 1,
		M_PING			= 2,
		M_ENC_KEY		= 4,
	}

	NetReader _reader;
	short[ushort] _lengths;

	short	_pid,
			_plen;

	uint _tick;
	ubyte _flags;
}
