module perfontain.math.matrix;

import
		std.math,
		std.range,
		std.string,
		std.traits,
		std.algorithm,
		std.exception,

		perfontain.misc,
		perfontain.math.m4x4,
		perfontain.math.square,
		perfontain.math.vector,
		perfontain.math.quaternion;

public import
				perfontain.math.constants;


auto zipMap(alias F, T, uint N)(auto ref in Matrix!(T, 1, N) a, auto ref in Matrix!(T, 1, N) b)
{
	Vector!(typeof(F(T.init, T.init)), N) res;

	foreach(i, ref v; res)
	{
		v = F(a[i], b[i]);
	}

	return res;
}

bool valueEqual(float a, float b) { return approxEqual(a, b); }
bool valueEqual(in float[] a, in float[] b) { return approxEqual(a, b); }

enum float TO_RAD = PI / 180;
enum float TO_DEG = 180 / PI;

enum
{
	MATRIX_QUATERNION = 1,
}

struct Matrix(T, uint _M, uint _N = _M, ubyte _F = 0)
{
	static assert(_N != 1 || _M != 1, `1x1 matrices are forbidden`);

	enum
	{
		M = _M, // rows
		N = _N, // columns
		C = M * N, // count of elements

		isSquare = M == N,
		isVector = N == 1 || M == 1,
		isQuaternion = !!(_F & MATRIX_QUATERNION),
		isFP = isFloatingPoint!T,
	}

	static
	{
		auto zero()
		{
			Matrix res;
			res.flat[] = 0;
			return res;
		}

	private:
		auto defaultMatrix()
		{
			T[C] arr = 0;

			static if(_F & MATRIX_QUATERNION)
			{
				arr[3] = 1;
			}
			else static if(isSquare)
			{
				foreach(i; 0..N)
				{
					arr[i * (N + 1)] = 1;
				}
			}

			return arr;
		}
	}

	union
	{
		T[C] flat = defaultMatrix;
		T[N][M] A;
	}

	auto ptr() @property inout { return flat.ptr; }

	const
	{
		auto toString() // TODO: REWRITE
		{
			enum DIGITS = 6;

			static if(isVector)
			{
				static if(isFP)
					return format(`[%-( %s%) ]`, (cast(T[])flat).map!(a => format(`%*s`, DIGITS, valueEqual(a, 0) ? 0 : a)[0..min(DIGITS, $)]));
				else
					return format(`[%( %s%) ]`, flat);
			}
			else
				return format("%(%s%|\n%)", this[]);
		}

		auto opBinary(string op : `*`, uint R)(auto ref in Matrix!(T, N, R) b)
		{
			Matrix!(T, M, R) ret = void;

			static foreach(i; 0..M)
			static foreach(j; 0..N)
			{
				{
					auto c = A[i][j];

					static foreach(k; 0..R)
					{
						static if(j)
						{
							ret.A[i][k] += b.A[j][k] * c;
						}
						else
						{
							ret.A[i][k] = b.A[j][k] * c;
						}
					}
				}
			}

			return ret;
		}

		auto opUnary(string op: `-`)()
		{
			Matrix ret = void;
			ret.flat[] = -flat[];
			return ret;
		}

		auto opBinary(string op)(T v) if(op == `+` || op == `-` || op == `*` || op == `/`)
		{
			Matrix ret = void;
			ret.flat[] = mixin(`flat[]` ~ op ~ `v`);
			return ret;
		}

		auto opBinary(string op)(auto ref in Matrix m) if(op == `+` || op == `-`)
		{
			Matrix ret = void;
			ret.flat[] = mixin(`flat[]` ~ op ~ `m.flat[]`);
			return ret;
		}

		auto transposed() @property
		{
			Matrix!(T, N, M) ret = void;

			foreach(i; 0..M)
			foreach(j; 0..N)
			{
				ret.A[j][i] = A[i][j];
			}

			return ret;
		}
	}

	ref opOpAssign(string op)(T v)
	{
		mixin(`flat[]` ~ op ~ `= v;`);
		return this;
	}

	ref opOpAssign(string op)(auto ref in Matrix m) { return this = opBinary!op(m); }

	static if(isVector)
	{
		ref opIndex(size_t i) inout { return flat[i]; }
	}
	else
	{
		ref opIndex(size_t i) inout
		{
			return *cast(Matrix!(T, 1, N)*)A[i].ptr;
		}

		inout opSlice()
		{
			return (cast(Matrix!(T, 1, N)*)flat.ptr)[0..M];
		}
	}

	static if(isSquare)
	{
		mixin SquareImpl;

		static if(isFloatingPoint!T && N == 4)
		{
			mixin M4x4Impl;
		}
	}

	static if(isVector)
	{
		mixin VectorImpl;

		static if(C == 3)
		{
			static if(isFP)
			{
				alias Quat = QuaternionT!T;
			}

			ref opOpAssign(string op: `*`, E)(auto ref in E e)
			{
				return this = this * e;
			}

		const:
			auto opBinary(string op: `^`)(auto ref in Matrix v)
			{
				return Matrix(
								y * v.z - z * v.y,
								z * v.x - x * v.z,
								x * v.y - y * v.x
													);
			}

			auto opBinary(string op: `*`)(auto ref in Quat q)
			{
				return (q * Quat(this, 0) * q.inversed).xyz;
			}

			auto opBinary(string op: `*`)(auto ref in Matrix!(T, 4) m)
			{
				auto v = Vector!(T, 4)(this, 1) * m;
				return v.xyz / v.w;
			}
		}

		static if(isQuaternion)
		{
			mixin QuaternionImpl;

			auto opBinary(string op: `*`)(auto ref in Matrix b) const
			{
				return Matrix(
								b.p * w + p * b.w + (p ^ b.p),
								w * b.w + p * b.p
													);
			}
		}
		else
		{
			auto opBinary(string op: `*`)(auto ref in Matrix b) const
			{
				return zip(b).map!(a => a[0] * a[1]).fold!((a, b) => a + b);
			}
		}
	}
}

alias Vector(T, uint M) = Matrix!(T, 1, M);

alias Matrix3 = Matrix!(float, 3);
alias Matrix4 = Matrix!(float, 4);

alias Vector2 = Vector!(float, 2);
alias Vector3 = Vector!(float, 3);
alias Vector4 = Vector!(float, 4);

alias QuaternionT(T) = Matrix!(T, 1, 4, MATRIX_QUATERNION);
alias Quaternion = QuaternionT!float;

alias Vertex = Vector!(float, 8);

alias Vector2s = Vector!(short, 2);
alias Vector3s = Vector!(short, 3);

alias Vector2i = Vector!(int, 2);

alias Vector2u = Vector!(uint, 2);
alias Vector3u = Vector!(uint, 3);
alias Vector4u = Vector!(uint, 4);

enum isMatrix(T) = is(T == Matrix!A, A...);

template isVector(T)
{
	static if(isMatrix!T) enum isVector = T.isVector;
	else enum isVector = false;
}

unittest
{
	alias T = double;

	Matrix!(T, 4) m;
	alias V4 = Vector!(T, 4);

	m[0] = V4(1.26, -2.34,  1.17, 1);
	m[1] = V4(0.75,  1.24, -0.48, 2);
	m[2] = V4(3.44, -1.85,  1.16, 3);
	m[3] = V4(9.44, -1.85,  7.16, 4);

	assert(valueEqual(m.det, 38.803188323974609375, 0.001));
}
