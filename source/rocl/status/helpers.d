module rocl.status.helpers;


mixin template StatusValue(T, string Name, alias F)
{
	@property
	{
		mixin(`const ` ~ Name ~ `() { return _` ~ Name ~ `; }`);
		mixin(`void ` ~ Name ~ `(T v) { if(_` ~ Name ~ ` != v) { _` ~ Name ~ ` = v; F(); } }`);
	}

	mixin(`private T _` ~ Name ~ `;`);
}

mixin template StatusIndex(string Name)
{
	@property idx() const
	{
		static if(is(typeof(this) == class))
		{
			alias F = a => a is this;
		}
		else
		{
			alias F = (ref a) => &a == &this;
		}

		return cast(ubyte)mixin(`RO.status.` ~ Name)[].countUntil!F;
	}
}
