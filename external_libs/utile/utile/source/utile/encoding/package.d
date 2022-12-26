module utile.encoding;

import std.conv, std.string, std.encoding, std.exception, std.windows.charset,

	core.stdc.errno, utile.except, utile.encoding.iconv;

static immutable string[ushort] encodingsTable;

shared static this()
{
	encodingsTable = [
		437: `IBM437`,
		708: `ASMO-708`,
		775: `IBM775`,
		850: `IBM850`,
		852: `IBM852`,
		855: `IBM855`,
		857: `IBM857`,
		860: `IBM860`,
		861: `IBM861`,
		863: `IBM863`,
		864: `IBM864`,
		865: `IBM865`,
		866: `CP866`,
		869: `IBM869`,
		874: `WINDOWS-874`,
		932: `SHIFT_JIS`,
		936: `GB2312`,
		949: `KS_C_5601-1987`,
		950: `BIG5`,
		1200: `UTF-16`,
		1250: `WINDOWS-1250`,
		1251: `WINDOWS-1251`,
		1252: `WINDOWS-1252`,
		1253: `WINDOWS-1253`,
		1254: `WINDOWS-1254`,
		1255: `WINDOWS-1255`,
		1256: `WINDOWS-1256`,
		1257: `WINDOWS-1257`,
		1258: `WINDOWS-1258`,
		1361: `JOHAB`,
		10000: `MACINTOSH`,
		12000: `UTF-32`,
		12001: `UTF-32BE`,
		20127: `US-ASCII`,
		20866: `KOI8-R`,
		20932: `EUC-JP`,
		21866: `KOI8-U`,
		28591: `ISO-8859-1`,
		28592: `ISO-8859-2`,
		28593: `ISO-8859-3`,
		28594: `ISO-8859-4`,
		28595: `ISO-8859-5`,
		28596: `ISO-8859-6`,
		28597: `ISO-8859-7`,
		28598: `ISO-8859-8`,
		28599: `ISO-8859-9`,
		28603: `ISO-8859-13`,
		28605: `ISO-8859-15`,
		50221: `CSISO2022JP`,
		50222: `ISO-2022-JP`,
		50225: `ISO-2022-KR`,
		51932: `EUC-JP`,
		51936: `EUC-CN`,
		51949: `EUC-KR`,
		52936: `HZ-GB-2312`,
		54936: `GB18030`,
		65000: `UTF-7`,
	];
}

auto decode(string s, ushort cp)
{
	version (linux)
	{
		s = iconv(s, encodingsTable[cp], `UTF-8`);
	}
	else
	{
		s = fromMBSz(s.toStringz, cp);
	}

	assert(s.isValid);
	return s;
}

auto encode(string s, ushort cp)
{
	assert(s.isValid);

	version (linux)
	{
		return iconv(s, `UTF-8`, encodingsTable[cp]);
	}
	else
	{
		return toMBSz(s, cp).fromStringz.assumeUnique;
	}
}
