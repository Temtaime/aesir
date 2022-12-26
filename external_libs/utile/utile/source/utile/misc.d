module utile.misc;
import std;

mixin template publicProperty(T, string Name, string Value = null)
{
	mixin(`
			public ref ` ~ Name ~ `() const @property => _` ~ Name ~ `;
			T _` ~ Name ~ (Value.length ? `=` ~ Value : null) ~ `;`);
}

auto as(T, E)(E data) if (isDynamicArray!E)
{
	return cast(T[])data;
}

auto as(T, E)(ref E data) if (!isDynamicArray!E)
{
	return cast(T[])(&data)[0 .. 1];
}

auto toByte(T)(auto ref T data)
{
	return data.as!ubyte;
}

string randomId(uint len = 16)
{
	return len.iota.map!(_ => fullHexDigits.byCodeUnit.choice).array;
}

void removeUnstable(T, A...)(ref T[] arr, A indices)
{
	arr = arr.remove!(SwapStrategy.unstable)(indices);
}
