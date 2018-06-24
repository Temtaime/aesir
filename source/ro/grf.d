module ro.grf;

import
		std.utf,
		std.conv,
		std.file,
		std.path,
		std.zlib,
		std.stdio,
		std.range,
		std.array,
		std.mmfile,
		std.string,
		std.datetime,
		std.algorithm,

		etc.c.zlib,

		perfontain.misc,
		perfontain.misc.rc,

		utils.except,
		utils.logger,
		utils.encoding;


string charsToString(T)(in T[] str) if(T.sizeof == 1)
{
	return cast(string)str.toByte.until(0).array;
}

string convertName(in char[] str)
{
	return str.charsToString.fromKorean;
}

char[N] stringToChars(uint N)(string s) // TODO: remove
{
	assert(s.length <= N);
	char[N] ret = 0;
	ret[0..s.length] = s;
	return ret;
}

final class Grf : RCounted
{
	this(string name, bool canWrite = false)
	{
		if(exists(_name = name))
		{
			_f = new MmFile(_name, canWrite ? MmFile.Mode.readWrite : MmFile.Mode.read, 0, null);

			try
			{
				_files = binaryReadFile!GrfCache(cachePath).files;
			}
			catch(Exception e)
			{
				logger.info3(`%s failed to load from cache`, _name);
				parseHeader;
			}
		}
		else
		{
			canWrite || throwError!`can't find file %s`(name);
			_modified = true;
		}
	}

	~this()
	{
		save;
		_f.destroy;
	}

	auto save()
	{
		if(_modified)
		{
			GFiles arr;

			foreach(n, ref f; _files)
			{
				arr.files ~= GrfFileImpl(n.toKorean, f.zlenAl, f.zlenAl, f.len, GRF_FLAG_FILE, f.off - GRF_HEADER_LEN);
			}

			auto buf = arr.binaryWrite;

			auto comp = compress(buf, Z_NO_COMPRESSION);
			auto zl = cast(uint)comp.length;

			GrfHeader h =
			{
				off: wastePos(zl + 8) - GRF_HEADER_LEN,
				filesCount: cast(uint)_files.length + 7,

				zlen: zl,
				len: cast(uint)buf.length,

				data: comp
			};

			binaryWrite(_f[], h, true);

			makeCache;
			_modified = false;
		}

		return this;
	}

	void put(string name, in void[] data)
	{
		remove(name);

		if(data.length)
		{
			auto buf = compress(data, Z_BEST_COMPRESSION);
			auto pos = wastePos(cast(uint)buf.length);

			_f[pos..pos + buf.length][] = buf;
			_files[name] = GrfFile(cast(uint)buf.length, cast(uint)data.length, pos);
		}
	}

	auto get(string name)
	{
		if(auto f = name in _files)
		{
			return uncompress(_f[f.off..f.off + f.zlenAl], f.len).toByte;
		}

		return null;
	}

	void remove(string name)
	{
		_files.remove(name);
		_modified = true;
	}

private:
	mixin publicProperty!(GrfFile[string], `files`);

	struct GFiles
	{
		@(`rest`) GrfFileImpl[] files;
	}

	auto cachePath()
	{
		SysTime
					access,
					modify;

		getTimes(_name, access, modify);

		return format(tempDir ~ `/%s-%u-%u.cache`, _name.stripExtension, modify.stdTime, _f.length);
	}

	void parseHeader()
	{
		auto h = _f[].binaryRead!GrfHeader(true);

		auto buf = uncompress(h.data, h.len);
		auto arr = buf.binaryRead!GFiles.files;

		foreach(ref t; arr)
		{
			t.off += GRF_HEADER_LEN;

			if(t.name.length && t.flags == GRF_FLAG_FILE && t.len && t.off + t.zlenAl <= _f.length)
			{
				_files[t.name.fromKorean] = GrfFile(t.zlenAl, t.len, t.off);
			}
		}

		makeCache;
	}

	void makeCache()
	{
		GrfCache cache =
		{
			_files
		};

		binaryWriteFile(cachePath, cache);
	}

	uint wastePos(uint len)
	{
		uint last = GRF_HEADER_LEN;

		foreach(ref f; _files.values.sort!((a, b) => a.off < b.off))
		{
			if(f.off - last >= len)
			{
				return last;
			}

			last = f.off + f.zlenAl;
		}

		auto k = last + len;

		if(!_f || k > _f.length)
		{
			_f.destroy;
			_f = new MmFile(_name, MmFile.Mode.readWrite, k, null);
		}

		return last;
	}

	MmFile _f;
	string _name;

	bool _modified;
}

private:

auto fromKorean(string s)
{
	return s.decode(51949).replace(`\`, `/`).toLower;
}

auto toKorean(string s)
{
	return s.replace(`/`, `\`).encode(51949);
}

enum
{
	GRF_FLAG_FILE = 1,
	GRF_HEADER_LEN = 46,
}

struct GrfFile
{
	uint zlenAl;
	uint len;
	uint off;
}

struct GrfHeader
{
	static immutable char[15] bom = `Master of Magic`;
	ubyte[15] encryption;

	uint
			off,
			waste,
			filesCount; // files.length + 7

	static immutable ver = 0x200;

	// HEADER DATA BEGINS
	@(`skip`, `off`) uint zlen;

	uint len;
	@(`length`, `zlen`) const(void)[] data;
}

struct GrfFileImpl
{
	string name;
	uint zlen;
	uint zlenAl;
	uint len;
	ubyte flags;
	uint off;
}

struct GrfCache
{
	static immutable
	{
		char[3] bom = `PGC`;
		ubyte v = 1;
	}

	@(`uint`) GrfFile[string] files;
}
