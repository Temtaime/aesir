module rocl.misc;

import
		std;


auto toStr(in ubyte[] arr)
{
	return arr.findSplitBefore(0.only)[0].assumeUTF.idup.sanitize;
}
