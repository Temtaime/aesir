module perfontain.managers.settings.data;
import std, perfontain;

enum Shadows
{
	none,
	low,
	medium,
	high,
	ultra
}

enum Lights
{
	off,
	global,
	full
}

package:

mixin template Setting(T, string Name, T Value)
{
	mixin(`private T _` ~ Name ~ ` = Value;

	T ` ~ Name ~ `() @property => _` ~ Name ~ `;
	void ` ~ Name ~ `(T value) @property => ` ~ Name
			~ `Change(_` ~ Name ~ ` = value);

perfontain.Signal!(void, T)` ~ Name ~ `Change;`);
}
