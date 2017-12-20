module rocl.misc;

import
		std.range,
		std.encoding,
		std.algorithm;


auto toStr(in ubyte[] arr)
{
	return (cast(string)arr.findSplitBefore(only(0))[0]).idup.sanitize;
}
