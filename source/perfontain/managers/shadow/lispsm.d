module perfontain.managers.shadow.lispsm;

import
		std.stdio,
		std.range,
		std.array,
		std.algorithm,

		perfontain;


struct Lispsm
{
	// DISAIPE WILL CODE HERE
}

// OLD INTERFACE TO THE LIBRARY
struct SceneData
{
	Matrix4 view, viewProjInversed;
	BBox box;
	Vector3 cameraPos, cameraDir, lightDir;
}

static assert(SceneData.sizeof == 188);

extern(C) void calculateShadowMatrices(void *, float *, float *, bool);
