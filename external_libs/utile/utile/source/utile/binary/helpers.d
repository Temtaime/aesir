module utile.binary.helpers;
import std.meta, std.traits, std.array, std.range, std.traits, utile.binary.attrs;

template isDataSimple(T)
{
	static if (isBasicType!T)
	{
		enum isDataSimple = true;
	}
	else static if (isStaticArray!T)
	{
		enum isDataSimple = isDataSimple!(ElementEncodingType!T);
	}
	else
	{
		enum isDataSimple = false;
	}
}

@property fieldsToProcess(T)()
{
	int k, sz;

	string u;
	string[] res;

	void add()
	{
		if (u.length)
		{
			res ~= u;
			u = null;
		}
	}

	foreach (name; __traits(allMembers, T))
	{
		static if (__traits(getProtection, __traits(getMember, T, name)) == `public`)
		{
			alias E = Alias!(__traits(getMember, T, name));

			static if (!(is(FunctionTypeOf!E == function) || hasUDA!(E, Ignored)))
			{
				static if (is(typeof(E.offsetof)) && isAssignable!(typeof(E)))
				{
					const x = E.offsetof, s = E.sizeof;

					if (k != x)
					{
						add;
						u = name;

						k = x;
						sz = s;
					}
					else if (s > sz)
					{
						u = name;
						sz = s;
					}
				}
				else static if (__traits(compiles, &E) && is(typeof(E) == immutable))
				{
					add;
					res ~= name;
				}
			}
		}
	}

	add;
	return res;
}
