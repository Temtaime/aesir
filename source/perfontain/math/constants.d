module perfontain.math.constants;

import perfontain.math.matrix;

static immutable
{
	auto AXIS_X = Vector3(1, 0, 0), AXIS_Y = Vector3(0, 1, 0),
		AXIS_Z = Vector3(0, 0, 1), VEC3_2 = Vector3(0.5);

	auto AXIS_FRONT = -AXIS_Z;
	auto AXIS_UP = AXIS_Y;
}
