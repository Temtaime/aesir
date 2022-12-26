module utile.encoding.iconv;

import std.conv, std.string, std.encoding, core.stdc.errno, utile.except;

version (linux)  : auto iconv(string s, string from, string to)
{
	auto q = to ~ `//IGNORE//TRANSLIT`;
	auto iv = iconv_open(q.toStringz, from.toStringz);

	cast(ptrdiff_t)iv != -1 || throwError!`can't convert from %s to %s`(from, to);

	scope (exit)
	{
		iconv_close(iv);
	}

	auto p = s.ptr;
	auto len = s.length;

	string res;
	char[2048] tmp = void;

	while (len)
	{
		auto b = tmp.ptr;
		auto bs = tmp.length;

		auto c = iconv(iv, cast(char**)&p, &len, &b, &bs);

		c != size_t.max || errno == E2BIG || throwError(`conversion error`);
		res ~= tmp[0 .. $ - bs];
	}

	return res;
}

extern (C):

void* iconv_open(in char*, in char*);
size_t iconv(void*, char**, size_t*, char**, size_t*);

int iconv_close(void*);
