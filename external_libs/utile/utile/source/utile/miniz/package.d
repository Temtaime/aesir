module utile.miniz;
import std.conv, std.file, std.array, std.stdio, std.string, std.algorithm,
	std.exception, utile.miniz.binding;

final class Zip
{
	this(string name, bool writeable = true, bool create = false)
	{
		auto s = name.toStringz;

		if (create)
		{
			assert(writeable, `cannot create in readonly mode`);

			mz_zip_writer_init_file_v2(&_zip, name.toStringz, 0,
					MZ_ZIP_FLAG_WRITE_ZIP64 | MZ_ZIP_FLAG_WRITE_ALLOW_READING);
		}
		else
		{
			enforce(name.exists, `archive does not exist`);

			mz_zip_reader_init_file(&_zip, s, 0);

			if (writeable)
			{
				mz_zip_writer_init_from_reader(&_zip, s);
			}
			else
			{
				_ro = true;
			}
		}
	}

	~this()
	{
		if (_ro)
		{
			mz_zip_reader_end(&_zip);
		}
		else
		{
			mz_zip_writer_finalize_archive(&_zip);
			mz_zip_writer_end(&_zip);
		}
	}

	auto get(string name)
	{
		auto idx = mz_zip_reader_locate_file(&_zip, name.toStringz, null, 0);
		enforce(idx >= 0, lastError);

		mz_zip_archive_file_stat s;
		enforce(mz_zip_reader_file_stat(&_zip, idx, &s), lastError);

		auto res = new ubyte[cast(size_t)s.m_uncomp_size];

		enforce(mz_zip_reader_extract_to_mem(&_zip, idx, res.ptr, res.length, 0), lastError);
		return res;
	}

	void put(string name, in void[] data)
	{
		mz_zip_writer_add_mem(&_zip, name.toStringz, data.ptr, data.length, 0);
	}

private:
	auto lastError()
	{
		return mz_zip_get_last_error(&_zip).mz_zip_get_error_string.fromStringz.assumeUnique;
	}

	bool _ro;
	mz_zip_archive _zip;
}
