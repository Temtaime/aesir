module perfontain.math.vector;

mixin template VectorImpl()
{
	this(A...)(auto ref in A args)
	{
		uint k;

		foreach(ref v; args)
		{
			static if(.isVector!(typeof(v)))
			{
				foreach(ref e; v.flat)
				{
					flat[k++] = cast(T)e;
				}
			}
			else
			{
				flat[k++] = cast(T)v;
			}
		}

		if(k == 1)
		{
			flat[k..$] = flat[0];
		}
		else
		{
			assert(k == C, `not all elements in the vector have a value`); // TODO: STATIC ASSERT
		}
	}

	@property inout ref
	{
		auto x()() if(C > 0) { return flat[0]; }
		auto y()() if(C > 1) { return flat[1]; }
		auto z()() if(C > 2) { return flat[2]; }
		auto w()() if(C > 3) { return flat[3]; }

		auto a()() if(C > 3) { return flat[3]; }
		auto b()() if(C > 4) { return flat[4]; }
		auto c()() if(C > 5) { return flat[5]; }

		auto u()() if(C > 6) { return flat[6]; }
		auto v()() if(C > 7) { return flat[7]; }

		auto p()() if(C > 2) { return *cast(inout(Vector3)*)(flat.ptr + 0); }
		auto n()() if(C > 5) { return *cast(inout(Vector3)*)(flat.ptr + 3); }
		auto t()() if(C > 7) { return *cast(inout(Vector2)*)(flat.ptr + 6); }
	}

	@property opDispatch(string s)() const if(s.length > 1)
	{
		Vector!(T, s.length) ret = void;

		foreach(i; IndexTuple!(ret.C))
		{
			ret[i] = mixin(`this.` ~ s[i]);
		}

		return ret;
	}

	inout opSlice()
	{
		return flat[];
	}

	static if(isFloatingPoint!T)
	{
		ref normalize()
		{
			return this /= length;
		}

	const
	@property:
		auto normalized()
		{
			return this / length;
		}

		auto length()
		{
			return flat.fold!((a, b) => a + b * b)(T(0)).sqrt;
		}
	}
}
