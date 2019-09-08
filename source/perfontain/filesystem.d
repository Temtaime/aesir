module perfontain.filesystem;

import
		std,

		perfontain.misc,
		utils.except;


enum
{
	FS_DISK,
	FS_TMP,
	FS_MEMORY,
}

class FileSystem
{
	this()
	{
		_temp = buildPath(tempDir, `__perfontain`);
	}

	~this()
	{
		try
		{
			if(_temp.exists)
			{
				rmdirRecurse(_temp);
			}
		}
		catch(Exception) {}
	}

	auto get(string name, string f = __FILE__, uint l = __LINE__)
	{
		struct S
		{
			@(`rest`) ubyte[] data;
		}

		return read!S(name, f, l).data;
	}

	auto read(T)(string name, string f = __FILE__, uint l = __LINE__)
	{
		T res;

		Rdg dg = (data, isPath)
		{
			data.length || throwError!`can't find file %s`(f, l, name);

			if(isPath)
			{
				res = binaryReadFile!T(data.assumeUTF, f, l);
			}
			else
			{
				res = data.binaryRead!T(false, f, l);
			}
		};

		doRead(name, dg);
		return res;
	}

	void put(string name, in void[] data, ubyte t = FS_DISK)
	{
		struct S
		{
			@(`rest`) const(void)[] data;
		}

		return write(name, S(data), t);
	}

	void write(T)(string name, auto ref in T data, ubyte t = FS_DISK)
	{
		Wdg dg = (name)
		{
			if(name.length)
			{
				name.binaryWriteFile(data);
				return null;
			}

			return binaryWrite(data).toByte;
		};

		doWrite(name, dg, t);
	}

protected:
	alias Rdg = void delegate(in ubyte[], bool);
	alias Wdg = const(ubyte)[] delegate(string);

	void doRead(string name, Rdg dg)
	{
		if(auto p = name in _files)
		{
			return dg(*p, false);
		}

		if(!name.exists)
		{
			name = buildPath(_temp, name);

			if(!name.exists)
			{
				return dg(null, false);
			}
		}

		dg(name.representation, true);
	}

	void doWrite(string name, Wdg dg, ubyte t)
	{
		final switch(t)
		{
		case FS_MEMORY:
			_files[name] = dg(null);
			return;

		case FS_DISK:
			break;

		case FS_TMP:
			name = buildPath(_temp, name);
		}

		mkdirRecurse(name.dirName);
		dg(name);
	}

private:
	string _temp;
	const(ubyte)[][string] _files;
}
