module perfontain.managers.render.drawinfo;

import
		perfontain;


enum
{
	DI_NO_DEPTH		= 1,
}

struct DrawInfo
{
	MeshHolder mh;
	Matrix4 matrix;

	uint	lightStart,
			lightEnd;

	Color color;
	ushort id;

	ubyte	flags,
			blendingMode;
package:
	static cmp(bool HolderToo)(ref in DrawInfo a, ref in DrawInfo b)
	{
		if((a.flags & DI_NO_DEPTH) != (b.flags & DI_NO_DEPTH))
		{
			return (a.flags & DI_NO_DEPTH) < (b.flags & DI_NO_DEPTH);
		}

		static if(HolderToo)
		{
			if(cast(void *)a.mh != cast(void *)b.mh)
			{
				return cast(void *)a.mh < cast(void *)b.mh;
			}
		}

		return a.blendingMode < b.blendingMode;
	}
}
