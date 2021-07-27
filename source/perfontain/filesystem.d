module perfontain.filesystem;
import std, perfontain.misc, utile.except;

enum
{
	FS_DISK,
	FS_MEMORY,
}

class FileSystem
{
	ubyte[] get(string name)
	{
		if (auto data = _files.get(name, null))
		{
			return data.dup;
		}

		if (name.exists)
		{
			return std.file.read(name).toByte;
		}

		return null;
	}

	void put(string name, in void[] data, ubyte t = FS_DISK)
	{
		final switch (t)
		{
		case FS_MEMORY:
			_files[name] = data.toByte.idup;
			return;

		case FS_DISK:
			break;
		}

		mkdirRecurse(name.dirName);
		std.file.write(name, data);
	}

	final read(T)(string name)
	{
		return get(name).deserializeMem!T;
	}

	final write(T)(string name, in T data, ubyte t = FS_DISK)
	{
		put(name, data.serializeMem, t);
	}

private:
	immutable(ubyte)[][string] _files;
}
