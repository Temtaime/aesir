module rocl.network.connection;
import std.socket, core.bitop, perfontain.misc, utile.except;

struct NetReader
{
	void connect(Address addr)
	{
		_sock = new TcpSocket(addr);
		_sock.blocking = false;
		//_sock.connect(addr);

		_km = 0x1F;
		_skm = 0x1E;
	}

	void close()
	{
		_sock.close;
		_sock = null;

		_ra = null;
		_wa = null;
	}

	@property alive()
	{
		return !!_sock;
	}

	auto read(uint len, bool reset = true)
	{
		if (_ra.length < len)
		{
			return null;
		}

		ubyte[] res;

		if (key)
		{
			res = new ubyte[len];

			foreach (i, ref v; res)
			{
				v = _ra[i];

				auto c = v & 0x11;
				v = ror(v, 4);

				v ^= kv[1];
				v -= kv[2];
				v ^= kv[0];
				v += kv[3];

				v ^= _ri++;
				v ^= _km;

				_km += c;
			}

			if (reset)
			{
				_ri = 0;
			}
		}
		else
		{
			res = _ra[0 .. len];
		}

		_ra = _ra[len .. $];
		return res;
	}

	void write(in void[] data, bool reset = true)
	{
		if (key)
		{
			_wa.length += data.length;

			foreach (i, v; data.toByte)
			{
				v ^= _skm;
				v ^= _wi++;

				v -= kv[2];
				v ^= kv[1];
				v += kv[3];
				v ^= kv[0];

				v = ror(v, 4);
				_skm += v & 0x15;

				_wa[$ - data.length + i] = v;
			}

			if (reset)
			{
				_wi = 0;
			}
		}
		else
		{
			_wa ~= data.toByte;
		}
	}

	void process()
	{
		{
			ubyte[8192] arr = void;
			auto len = _sock.receive(arr);

			if (!len)
			{
				close;
				throwError(`connection was closed`);
			}

			if (len == Socket.ERROR)
			{
				wouldHaveBlocked || throwError!`socket reading error: %s`(lastSocketError);
			}
			else
			{
				_ra ~= arr[0 .. len];
			}
		}

		if (_wa.length)
		{
			auto len = _sock.send(_wa);

			if (len == Socket.ERROR)
			{
				wouldHaveBlocked || throwError!`socket writing error: %s`(lastSocketError);
			}
			else
			{
				_wa = _wa[len .. $];
			}
		}
	}

	union
	{
		uint key;
		ubyte[4] kv;
	}

private:
	ubyte _km;
	ubyte _skm;

	ushort _wi;
	ushort _ri;

	ubyte[] _ra;
	ubyte[] _wa;

	TcpSocket _sock;
}
