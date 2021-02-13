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
	mixin(`T ` ~ Name ~ ` = Value;
perfontain.Signal!(void, T)` ~ Name ~ `Change;`);
}
