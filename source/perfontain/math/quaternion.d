module perfontain.math.quaternion;

mixin template QuaternionImpl()
{
	private alias V3 = Vector!(T, 3);

	// static lookAt(V3 source, V3 dest, V3 up)
	// {
	// 	T dot = source * dest;

	// 	if (approxEqual(dot, -1))
	// 		assert(false); //return new Quaternion(up, MathHelper.ToRadians(180.0f));

	// 	if (approxEqual(dot, 1))
	// 		assert(false); //return Matrix.init;

	// 	auto rotAngle = acos(dot);
	// 	auto rotAxis = source ^ dest;

	// 	return fromAxis(rotAxis.normalize, rotAngle);
	// }

	static lookAt(in V3 dir, in V3 front, in V3 up)
	{
		//compute rotation axis
		V3 rotAxis = front ^ dir; /* front.cross(toVector).normalized();
		if (rotAxis.squaredNorm() == 0)
			rotAxis = up;*/

		//find the angle around rotation axis
		T dot = front * dir;
		T ang = acos(dot);

		//convert axis angle to quaternion
		return fromAxis(rotAxis, ang);
	}

	static fromMatrix()(in Matrix!(T, 4) m)
	{
		/*Matrix ret = void;

		auto m0 = m[0][0];
		auto m1 = m[1][1];
		auto m2 = m[2][2];

		ret.x = max(0, 1 + m0 - m1 - m2).sqrt / 2;
		ret.y = max(0, 1 - m0 + m1 - m2).sqrt / 2;
		ret.z = max(0, 1 - m0 - m1 + m2).sqrt / 2;
		ret.w = max(0, 1 + m0 + m1 + m2).sqrt / 2;

		auto a = m[2][1] - m[1][2];
		auto b = m[0][2] - m[2][0];
		auto c = m[1][0] - m[0][1];

		ret.x *= sgn(ret.x * a);
		ret.y *= sgn(ret.y * b);
		ret.z *= sgn(ret.z * c);

		return ret;*/

		auto tr = m.tr;
		assert(tr > 0 && !valueEqual(tr, 0), `can't create quaternion from matrix`);

		auto a = m[2][1] - m[1][2], b = m[0][2] - m[2][0], c = m[1][0] - m[0][1], s = .5 / sqrt(tr);

		return Matrix(V3(a, b, c) * s, .25 / s);
	}

	static fromAxis()(in V3 axis, float angle)
	{
		angle /= 2;
		return Matrix(axis * angle.sin, angle.cos);
	}

	@property const
	{
		Matrix inversed()
		{
			return Matrix(-p, w);
		}
	}

	ref inverse()
	{
		p = -p;
		return this;
	}

	auto toMatrix() const
	{
		Matrix!(T, 4) res;

		auto xx = x * x, xy = x * y, xz = x * z, xw = x * w, yy = y * y, yz = y * z, yw = y * w, zz = z * z, zw = z * w;

		res[0][0] = 1 - 2 * (yy + zz);
		res[0][1] = 2 * (xy + zw);
		res[0][2] = 2 * (xz - yw);

		res[1][0] = 2 * (xy - zw);
		res[1][1] = 1 - 2 * (xx + zz);
		res[1][2] = 2 * (yz + xw);

		res[2][0] = 2 * (xz + yw);
		res[2][1] = 2 * (yz - xw);
		res[2][2] = 1 - 2 * (xx + yy);

		return res;
	}
}
