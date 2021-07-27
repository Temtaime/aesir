module perfontain.managers.render.drawinfo;
import perfontain;

enum
{
	DI_NO_DEPTH = 1,
}

struct DrawInfo
{
	Program prog;
	MeshHolder mh;

	Matrix4 matrix;
	Vector4s scissor;

	Color color = colorWhite;
	ushort id;

	ubyte flags, blendingMode = noBlending;
package:
	static diff(string val, string cmp = `<`, string as = ``)
	{
		return `if(` ~ as ~ `(a.` ~ val ~ `) != ` ~ as ~ `(b.` ~ val ~ `)) return ` ~ as ~ `(a.` ~ val ~ `) ` ~ cmp ~ as ~ `(b.` ~ val
			~ `);`;
	}

	static cmp(in DrawInfo a, in DrawInfo b)
	{
		mixin(diff(`prog`, `<`, `cast(void*)`));
		mixin(diff(`flags & DI_NO_DEPTH`));
		mixin(diff(`mh`, `<`, `cast(void*)`));

		return a.blendingMode < b.blendingMode;
	}
}
