module rocl.opti;

import
		std.experimental.all,

		etc.c.zlib,

		perfontain.misc,
		perfontain.misc.rc,

		tt.error;


final class Opti : RCounted
{
	this(string name, bool rw = false)
	{
		if(exists(_name = name))
		{
			_f = new MmFile(_name, rw ? MmFile.Mode.readWrite : MmFile.Mode.read, 0, null);
			parseHeader;
		}
		else
		{
			rw || throwError(`opti file is not found`);
		}

		_rw = rw;
	}

	~this()
	{
		_f.destroy;
	}

	void put(string name, in void[] data)
	{
		checkWriteable;

		if(data.length)
		{
			auto len = cast(uint)data.length;
			ensureSpace(len);

			{
				auto res = _f[_last.._last + len];
				process(data, res);
			}

			_files[name] = OpFile(_last, len);
			_last += len;

			save;
		}
		else
		{
			remove(name);
		}
	}

	auto get(string name)
	{
		if(auto f = name in _files)
		{
			auto res = new ubyte[f.len];

			process(_f[f.off..f.off + f.len], res);
			return res;
		}

		return null;
	}

	void remove(string name)
	{
		checkWriteable;

		if(name in _files)
		{
			_files.remove(name);
			save;
		}
	}

private:
	mixin publicProperty!(OpFile[string], `files`);

	static immutable ubyte[] KEY =
	[
		0x79, 0xd1, 0x02, 0x9f, 0x14, 0x8a, 0x14, 0x0e, 0xf8, 0x60, 0x7b, 0x97, 0xa9, 0x32, 0xfb, 0xfd
	];

	static process(in void[] data, void[] res)
	{
		foreach(i, v; data.toByte)
		{
			res.toByte[i] = v ^ KEY[i % $];
		}
	}

	void checkWriteable()
	{
		_rw || throwError(`opti file is readonly`);
	}

	void save()
	{
		OpHeader op;

		{
			auto fs = OpFiles(_files);
			auto data = fs.binaryWrite.toByte; // TODO: return void data

			process(data, data);

			op.len = cast(uint)data.length;
			op.header = data;
		}

		ensureSpace(op.len);
		binaryWrite(_f[], op);
	}

	void parseHeader()
	{
		auto h = _f[].binaryRead!OpHeader;
		auto data = h.header;

		process(data, data);
		_files = data.binaryRead!OpFiles.files;
	}

	void ensureSpace(uint len)
	{
		auto k = _last + len;

		if(!_f || k > _f.length)
		{
			_f.destroy;
			_f = new MmFile(_name, MmFile.Mode.readWrite, k, null);
		}
	}

	MmFile _f;
	string _name;

	bool _rw;
	ulong _last = HEADER_LEN;
}

private:

enum
{
	HEADER_LEN = 8
}

struct OpHeader
{
	static immutable
	{
		char[3] bom = `OPT`;
		ubyte ver = 1;
	}

	uint len;
	@(`skip`, `READER.length - len`, `rest`) ubyte[] header;
}

struct OpFiles
{
	@(`uint`) OpFile[string] files;
}

struct OpFile
{
	ulong off;
	uint len;
}
