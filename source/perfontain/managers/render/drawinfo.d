module perfontain.managers.render.drawinfo;

import
		perfontain;


enum
{
	DI_NO_DEPTH		= 1,
}

struct DrawInfo
{
	Program prog;
	MeshHolder mh;

	Matrix4 matrix;

	uint	lightStart,
			lightEnd;

	Color color;
	ushort id;

	ubyte	flags,
			blendingMode;
package:
	static diff(string val, string cmp = `<`, string as = ``)
	{
		return `if(` ~ as ~ `(a.` ~ val ~ `) != ` ~ as ~ `(b.` ~ val ~ `)) return ` ~ as ~ `(a.` ~ val ~ `) ` ~ cmp ~ as ~ `(b.` ~ val ~ `);`;
	}

	static cmp(bool Holder)(ref in DrawInfo a, ref in DrawInfo b)
	{
		mixin(diff(`prog`, `<`, `cast(void*)`));
		mixin(diff(`flags & DI_NO_DEPTH`));

		static if(Holder)
		{
			mixin(diff(`mh`, `<`, `cast(void*)`));
		}

		return a.blendingMode < b.blendingMode;
	}
}
