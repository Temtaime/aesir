module perfontain.managers.scene.structs;

import
		perfontain;


struct LightSource
{
	Vector3
				pos,
				color;

	float range;
}

final class Scene : RCounted
{
	RC!Node node;

	LightSource[] lights;
	ushort[] lightIndices;

	Vector3
				ambient,
				diffuse,
				lightDir,
				fogColor;

	float
			fogFar,
			fogNear;
}
