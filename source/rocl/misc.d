module rocl.misc;

import
		std.experimental.all;


auto toStr(in ubyte[] arr)
{
	return arr.findSplitBefore(0.only)[0].assumeUTF.idup.sanitize;
}
