module perfontain.filesystem;
import std, perfontain.misc, utile.except;

enum
{
	FS_DISK,
	FS_MEMORY,
}

class FileSystem
{
	ubyte[] get(string name, string f = __FILE__, uint l = __LINE__)
	{
		if (auto data = _files.get(name, null))
			return data.dup;

		name.exists || throwError!`can't find file %s`(f, l, name);
		return std.file.read(name).toByte;
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

	final read(T)(string name, string f = __FILE__, uint l = __LINE__)
	{
		return get(name, f, l).deserializeMem!T;
	}

	final write(T)(string name, auto ref in T data, ubyte t = FS_DISK)
	{
		put(name, data.serializeMem, t);
	}

private:
	immutable(ubyte)[][string] _files;
}
