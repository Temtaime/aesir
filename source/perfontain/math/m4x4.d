module perfontain.math.m4x4;

mixin template M4x4Impl()
{
	private alias V3 = Vector!(T, 3);

	@property inout
	{
		ref translation()
		{
			return *cast(inout(V3)*)A[3].ptr;
		}

		auto scale()
		{
			V3 res;
			foreach (i; 0 .. 3)
				res[i] = A[i][i];
			return res;
		}
	}

static:
	Matrix scale()(in V3 v)
	{
		return scale(v.x, v.y, v.z);
	}

	Matrix rotate()(in V3 v)
	{
		return rotate(v.x, v.y, v.z);
	}

	Matrix translate()(in V3 v)
	{
		return translate(v.x, v.y, v.z);
	}

	Matrix scale()(T x, T y, T z)
	{
		Matrix ret;
		ret.A[0][0] = x;
		ret.A[1][1] = y;
		ret.A[2][2] = z;
		return ret;
	}

	Matrix rotate()(T x, T y, T z)
	{
		auto res = rotateVector(AXIS_Y, y);
		res *= rotateVector(AXIS_X, x);
		res *= rotateVector(AXIS_Z, z);
		return res;
	}

	Matrix translate()(T x, T y, T z)
	{
		Matrix ret;
		ret.A[3][0] = x;
		ret.A[3][1] = y;
		ret.A[3][2] = z;
		return ret;
	}

	Matrix rotateVector()(in V3 axis, float angle)
	{
		float c = cos(angle);
		float s = sin(angle);
		float t = 1 - c;

		float tx = t * axis.x;
		float ty = t * axis.y;
		float tz = t * axis.z;

		float sx = s * axis.x;
		float sy = s * axis.y;
		float sz = s * axis.z;

		Matrix ret;

		ret.flat[0] = tx * axis.x + c;
		ret.flat[1] = tx * axis.y + sz;
		ret.flat[2] = tx * axis.z - sy;

		ret.flat[4] = ty * axis.x - sz;
		ret.flat[5] = ty * axis.y + c;
		ret.flat[6] = ty * axis.z + sx;

		ret.flat[8] = tz * axis.x + sy;
		ret.flat[9] = tz * axis.y - sx;
		ret.flat[10] = tz * axis.z + c;

		return ret;
	}

	Matrix makePerspective(float aspect, float fov = 45, float near = 0.1, float far = 5000)
	{
		Matrix res;
		res.flat[] = 0;

		auto t = 1 / (far - near);
		auto f = 1 / tan(fov * TO_RAD * 0.5);

		res[0][0] = -1 * f / aspect; // -1 right handed, 1 left handed
		res[1][1] = f;
		res[2][2] = far * t;
		res[3][2] = (-far * near) * t;
		res[2][3] = 1;

		return res;
	}

	Matrix lookAt(in V3 pos, in V3 dir)
	{
		auto z = dir;
		auto x = (AXIS_Y ^ z).normalize;
		auto y = z ^ x;

		Matrix ret;

		ret.A[0][0] = x.x;
		ret.A[1][0] = x.y;
		ret.A[2][0] = x.z;

		ret.A[0][1] = y.x;
		ret.A[1][1] = y.y;
		ret.A[2][1] = y.z;

		ret.A[0][2] = z.x;
		ret.A[1][2] = z.y;
		ret.A[2][2] = z.z;

		ret.translation = -V3(x * pos, y * pos, z * pos);
		return ret;
	}

	Matrix makeOrthogonal(float left, float right, float bottom, float top, float zNear, float zFar)
	{
		float tx = -(right + left) / (right - left);
		float ty = -(top + bottom) / (top - bottom);
		float tz = -(zFar + zNear) / (zFar - zNear);

		Matrix ret;

		ret.A[0][0] = 2 / (right - left);
		ret.A[1][1] = 2 / (top - bottom);
		ret.A[2][2] = -2 / (zFar - zNear);

		ret.A[3][0] = tx;
		ret.A[3][1] = ty;
		ret.A[3][2] = tz;

		return ret;
	}

	Matrix yaw(float angle)
	{
		float sa = sin(angle);
		float ca = cos(angle);

		Matrix ret;

		ret.A[0][0] = ca;
		ret.A[0][1] = sa;
		ret.A[1][0] = -sa;
		ret.A[1][1] = ca;

		return ret;
	}

	Matrix pitch(float angle)
	{
		float sa = sin(angle);
		float ca = cos(angle);

		Matrix ret;

		ret.A[1][1] = ca;
		ret.A[1][2] = sa;
		ret.A[2][1] = -sa;
		ret.A[2][2] = ca;

		return ret;
	}

	Matrix roll(float angle)
	{
		float sa = sin(angle);
		float ca = cos(angle);

		Matrix ret;

		ret.A[0][0] = ca;
		ret.A[0][2] = -sa;
		ret.A[2][0] = sa;
		ret.A[2][2] = ca;

		return ret;
	}
}
