module perfontain.math.square;

mixin template SquareImpl()
{
	this(uint K)(in Matrix!(T, K) m) if (K != N)
	{
		enum L = min(N, K);

		foreach (i; 0 .. L)
		{
			A[i][0 .. L] = m.A[i][0 .. L];
		}
	}

	ref transpose()
	{
		static foreach (i; 0 .. N)
			static foreach (j; i + 1 .. N)
				{
				swap(A[i][j], A[j][i]);
			}

		return this;
	}

	ref inverse()
	{
		return this = inversed;
	}

	const
	{
		T det()
		{
			static if (N == 2)
			{
				return A[0][0] * A[1][1] - A[0][1] * A[1][0];
			}
			else
			{
				T ret = 0;

				static foreach (k; 0 .. N)
				{
					ret += A[0][k] * cofactor!(0, k);
				}

				return ret;
			}
		}

		private
		{
			auto minor(uint I, uint J)()
			{
				enum K = N - 1;
				Matrix!(T, K) sub = void;

				static foreach (i; 0 .. K)
					static foreach (j; 0 .. K)
						{
						{
							enum L = i >= I ? i + 1 : i;
							enum P = j >= J ? j + 1 : j;

							sub[i][j] = A[L][P];
						}
					}

				return sub.det;
			}

			auto cofactor(uint I, uint J)()
			{
				static if ((I + J) % 2)
				{
					return -minor!(I, J);
				}
				else
				{
					return minor!(I, J);
				}
			}
		}

		@property
		{
			auto inversed()
			{
				T det = 0;
				auto res = adj;

				foreach (i, ref v; res.A)
				{
					det += v[0] * flat[i];
				}

				res.flat[] /= det;
				return res;
			}

			auto adj()
			{
				Matrix ret = void;

				static if (N == 2)
				{
					ret[0][0] = A[1][1];
					ret[0][1] = -A[0][1];
					ret[1][0] = -A[1][0];
					ret[1][1] = A[0][0];
				}
				else
				{
					static foreach (i; 0 .. N)
						static foreach (j; 0 .. N)
							{
							ret[i][j] = cofactor!(i, j);
						}

					ret.transpose;
				}

				return ret;
			}

			auto tr()
			{
				T ret = 0;

				foreach (i, ref v; A)
				{
					ret += v[i];
				}

				return ret;
			}
		}
	}
}
