module perfontain.managers.gui.property;
import std, perfontain;

alias PropertyInt = Property!int;
alias PropertyFloat = Property!float;

final class Property(T) : GUIElement if (is(T == int) || is(T == float))
{
	this(Layout layout, string name, T min, T value, T max, T step, T incPerPixel)
	{
		super(layout);

		_name = name;

		_min = min;
		_max = max;
		_value = value;

		assert(_value >= _min && _value <= _max);

		_step = step;
		_incPerPixel = incPerPixel;
	}

	override void draw()
	{
		T prev = _value;

		static if (is(T == int))
			nk_property_int(ctx, _name.toStringz, _min, &_value, _max, _step, _incPerPixel);
		else static if (is(T == float))
			nk_property_float(ctx, _name.toStringz, _min, &_value, _max, _step, _incPerPixel);
		else
			static assert(false);

		if (_value != prev && onChange)
			onChange(_value);
	}

	void delegate(T) onChange;
private:
	mixin publicProperty!(T, `value`);

	string _name;
	T _min, _max, _step, _incPerPixel;
}
